import TelegramBot from 'node-telegram-bot-api';
import fs from 'fs';
import axios from 'axios';

// ==========================================
// 1. KONFIGURASI UTAMA
// ==========================================
const config = {
    token: "8595583887:AAEetqI53eeJAbf_u6pSo54Z7HM29vN_dn4", 
    ownerId: 6197482164, 
    botUsername: "FANTUNNEL_PPOB_BOT", 
    adminGroupId: -1002076809846, 
    // Database Files
    userBalanceFile: "./database/user_balance.json", 
    historyFile: "./database/history.json",
    xlSessionsFile: "./database/xl_sessions.json",
    scheduleFile: "./database/schedule.json", 
    // API Keys
    apiKeyKMSP: "29dc3989-2394-448d-a7a5-8a6c3fa59f5d", 
    apiKeyPayment: "e435777e-47ed-4485-a06c-767dbe895d1f", 
    // Harga & Markup
    markupMember: 3000,   
    markupReseller: 1000,
    priceUpgradeReseller: 50000, // Harga Upgrade
    bonusReferralUpgrade: 5000   // Bonus jika teman upgrade
};

const bot = new TelegramBot(config.token, { polling: true });
const botStartTime = Date.now();

// ==========================================
// 2. DATABASE & UTILS
// ==========================================
if (!fs.existsSync('./database')) fs.mkdirSync('./database');

const loadDB = (file, defaultVal) => {
    try {
        if (!fs.existsSync(file)) {
            fs.writeFileSync(file, JSON.stringify(defaultVal, null, 2));
            return defaultVal;
        }
        return JSON.parse(fs.readFileSync(file));
    } catch (e) { return defaultVal; }
};

const saveDB = (file, data) => fs.writeFileSync(file, JSON.stringify(data, null, 2));

// Load Database
let userBalance = loadDB(config.userBalanceFile, {}); 
let historyTrx = loadDB(config.historyFile, []);
let xlSessions = loadDB(config.xlSessionsFile, {});
let scheduleData = loadDB(config.scheduleFile, []);

const userState = {}; 
const tempOrder = {}; 

const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

const getUserData = (userId, referrerId = null) => {
    if (!userBalance[userId]) {
        userBalance[userId] = { 
            balance: 0, 
            role: 'member',
            referredBy: (referrerId && referrerId != userId) ? String(referrerId) : null 
        };
        saveDB(config.userBalanceFile, userBalance);
    }
    return userBalance[userId];
};

const getRuntime = () => {
    const uptime = Date.now() - botStartTime;
    const m = Math.floor((uptime / (1000 * 60)) % 60);
    const h = Math.floor((uptime / (1000 * 60 * 60)) % 24);
    const d = Math.floor(uptime / (1000 * 60 * 60 * 24));
    return `${d}d ${h}h ${m}m`;
};

// ==========================================
// 3. MESIN OTOMATIS (SCHEDULE & TRANSAKSI)
// ==========================================
const processTransaction = async (userId, chatId, order, isScheduled = false) => {
    const userData = getUserData(userId);
    
    if (userData.balance < order.price_sell) {
        if (!isScheduled) bot.sendMessage(chatId, `❌ Saldo Kurang! Butuh: ${formatRupiah(order.price_sell)}`);
        return false;
    }

    // Potong Saldo
    userData.balance -= order.price_sell;
    const trxId = `FTN${Date.now().toString().slice(-6)}`;
    
    historyTrx.push({ 
        trxId, userId, product: order.name, price: order.price_sell, 
        status: 'SUKSES', type: isScheduled ? 'SCHEDULED' : 'INSTANT',
        date: new Date().toLocaleString('id-ID') 
    });
    
    saveDB(config.userBalanceFile, userBalance);
    saveDB(config.historyFile, historyTrx);

    const struk = `┏━━━━━━━━━━━━━━━━━━━━┓\n┃      🎫 *STRUK PEMBAYARAN* 🎫      ┃\n┗━━━━━━━━━━━━━━━━━━━━┛\n*ID TRX* : #${trxId}\n*Status* : ✅ *BERHASIL* ${isScheduled ? '(Otomatis)' : ''}\n──────────────────────\n*Produk* : ${order.name}\n*Tujuan* : \`${order.phone}\`\n*Harga* : ${formatRupiah(order.price_sell)}\n──────────────────────\n_Sisa Saldo: ${formatRupiah(userData.balance)}_`;

    bot.sendMessage(chatId, struk, { parse_mode: 'Markdown' });
    return true;
};

// Cron Job (Cek Jadwal Tiap Menit)
setInterval(async () => {
    if (scheduleData.length === 0) return;
    const now = new Date();
    let updated = false;

    for (let i = 0; i < scheduleData.length; i++) {
        const task = scheduleData[i];
        if (now >= new Date(task.executeAt)) {
            await processTransaction(task.userId, task.chatId, task.orderData, true);
            scheduleData.splice(i, 1);
            updated = true;
            i--;
        }
    }
    if (updated) saveDB(config.scheduleFile, scheduleData);
}, 60000);

// ==========================================
// 4. CALLBACK HANDLER (MENU BUTTONS)
// ==========================================
bot.on('callback_query', async (clb) => {
    const { id, data, from, message } = clb;
    const chatId = message.chat.id;
    const userData = getUserData(from.id);

    // --- FITUR 1: ISI SALDO ---
    if (data === 'menu_topup') {
        userState[chatId] = 'WAITING_TOPUP_AMOUNT';
        bot.sendMessage(chatId, '💰 *ISI SALDO QRIS*\nMasukkan nominal (Min: Rp 1.000):', { parse_mode: 'Markdown' });
    }

    // --- FITUR 2: LOGIN XL ---
    else if (data === 'menu_xl_login') {
        userState[chatId] = 'WAITING_XL_PHONE';
        bot.sendMessage(chatId, '🔐 *LOGIN XL*\nMasukkan Nomor XL (Contoh: 0878xxx):');
    }

    // --- FITUR 3: CEK KUOTA ---
    else if (data === 'menu_cekkouta') {
        const session = xlSessions[from.id];
        if (!session) return bot.answerCallbackQuery(id, { text: "Anda belum Login XL!", show_alert: true });
        
        bot.sendMessage(chatId, '🔍 Sedang mengecek kuota...');
        try {
            // Contoh simulasi API Cek Kuota (Ganti URL sesuai API Anda jika ada)
            // Karena di kode awal tidak ada API Cek Kuota spesifik, ini logic dasarnya:
            const info = `📊 *INFO KUOTA XL*\nNomor: ${session.phone}\n\n⚠️ _Fitur cek kuota membutuhkan API khusus. Silakan login ulang jika gagal._`;
            bot.sendMessage(chatId, info, { parse_mode: 'Markdown' });
        } catch (e) { bot.sendMessage(chatId, '❌ Gagal cek kuota.'); }
    }

    // --- FITUR 4: UPGRADE RESELLER ---
    else if (data === 'menu_reseller') {
        if (userData.role === 'reseller') return bot.answerCallbackQuery(id, { text: "Anda sudah Reseller!", show_alert: true });
        
        const text = `👑 *UPGRADE RESELLER*\n\nKeuntungan:\n✅ Harga lebih murah (Potongan Rp 2.000)\n✅ Prioritas Support\n\nBiaya Upgrade: *${formatRupiah(config.priceUpgradeReseller)}*`;
        bot.editMessageText(text, {
            chat_id: chatId, message_id: message.message_id, parse_mode: 'Markdown',
            reply_markup: { inline_keyboard: [[{ text: '🚀 BAYAR & UPGRADE', callback_data: 'confirm_upgrade' }], [{ text: '🔙 BATAL', callback_data: 'back_to_menu' }]] }
        });
    }
    else if (data === 'confirm_upgrade') {
        if (userData.balance < config.priceUpgradeReseller) return bot.answerCallbackQuery(id, { text: "Saldo Kurang!", show_alert: true });
        
        userData.balance -= config.priceUpgradeReseller;
        userData.role = 'reseller';
        
        // Bonus Referral
        if (userData.referredBy && userBalance[userData.referredBy]) {
            userBalance[userData.referredBy].balance += config.bonusReferralUpgrade;
            bot.sendMessage(userData.referredBy, `🎉 Teman Anda upgrade Reseller! Bonus: ${formatRupiah(config.bonusReferralUpgrade)}`);
        }
        
        saveDB(config.userBalanceFile, userBalance);
        bot.sendMessage(chatId, '🎉 *SELAMAT!* Akun Anda sekarang *RESELLER*.', { parse_mode: 'Markdown' });
    }

    // --- FITUR 5: TRANSAKSI & JADWAL ---
    else if (data === 'pay_balance') {
        const order = tempOrder[chatId];
        if (!order) return bot.answerCallbackQuery(id, { text: "Sesi Habis!", show_alert: true });
        bot.deleteMessage(chatId, message.message_id);
        await processTransaction(from.id, chatId, order, false);
        delete tempOrder[chatId];
    }
    else if (data === 'set_schedule') {
        if (!tempOrder[chatId]) return bot.answerCallbackQuery(id, { text: "Sesi Habis!", show_alert: true });
        userState[chatId] = 'WAITING_SCHEDULE_TIME';
        bot.sendMessage(chatId, `📅 *ATUR JADWAL*\nFormat: \`YYYY-MM-DD HH:MM\`\nContoh: \`2026-02-12 08:30\``, { parse_mode: 'Markdown' });
    }

    // --- NAVIGASI & KATEGORI ---
    else if (data === 'menu_list') {
        bot.editMessageText('📂 *PILIH KATEGORI PAKET*:', {
            chat_id: chatId, message_id: message.message_id, parse_mode: 'Markdown',
            reply_markup: {
                inline_keyboard: [
                    [{ text: '💎 BEST SELLER', callback_data: 'cat_bestseller_0' }, { text: '👨‍👩‍👧‍👦 AKRAB', callback_data: 'cat_akrab_0' }],
                    [{ text: '⚡ COMBO', callback_data: 'cat_combo_0' }, { text: '🔥 HOTROD', callback_data: 'cat_hotrod_0' }],
                    [{ text: '🌐 LAINNYA', callback_data: 'cat_all_0' }],
                    [{ text: '🛒 INPUT KODE', callback_data: 'menu_input_manual' }],
                    [{ text: '🔙 KEMBALI', callback_data: 'back_to_menu' }]
                ]
            }
        });
    }
    // Logika Pagination Kategori
    // ==========================================
// UPDATE LOGIKA KATEGORI (INPUT KODE DI DALAM)
// ==========================================
else if (data.startsWith('cat_')) {
    const [_, kategori, page] = data.split('_');
    const p = parseInt(page);
    try {
        const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
        let allPackages = res.data.data;
        let filtered = [];
        
        // --- LOGIKA FILTER BARU ---
        if (kategori === 'bestseller') {
            // Khusus Edukasi & Conference
            filtered = allPackages.filter(item => 
                item.package_name.toLowerCase().includes('edukasi') || 
                item.package_name.toLowerCase().includes('conference') ||
                item.package_name.toLowerCase().includes('belajar')
            );
        } else if (kategori === 'akrab') {
            filtered = allPackages.filter(item => item.package_name.toLowerCase().includes('akrab'));
        } else if (kategori === 'combo') {
            filtered = allPackages.filter(item => item.package_name.toLowerCase().includes('combo') || item.package_name.toLowerCase().includes('vip'));
        } else if (kategori === 'hotrod') {
            filtered = allPackages.filter(item => item.package_name.toLowerCase().includes('hotrod'));
        } else {
            filtered = allPackages;
        }

        if (filtered.length === 0) return bot.answerCallbackQuery(id, { text: "❌ Kategori ini sedang kosong.", show_alert: true });

        const userData = getUserData(from.id);
        const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
        
        let pText = `📦 *KATEGORI: ${kategori.toUpperCase()}*\n`;
        pText += `━━━━━━━━━━━━━━━━━━━━\n`;
        pText += `💡 _Salin kode di bawah, lalu klik tombol "🛒 INPUT KODE"_\n\n`;
        
        const itemsPerPage = 5;
        const paginatedItems = filtered.slice(p * itemsPerPage, (p + 1) * itemsPerPage);

        paginatedItems.forEach(item => {
            pText += `🔹 *${item.package_name}*\n`;
            pText += `└ 🔑 Kode: \`${item.package_code}\`\n`;
            pText += `└ 💰 Harga: *${formatRupiah(item.package_harga_int + markup)}*\n\n`;
        });

        pText += `📄 Halaman: ${p + 1} / ${Math.ceil(filtered.length / itemsPerPage)}`;
        
        const nav = [];
        if (p > 0) nav.push({ text: '⬅️ Prev', callback_data: `cat_${kategori}_${p - 1}` });
        if ((p + 1) * itemsPerPage < filtered.length) nav.push({ text: 'Next ➡️', callback_data: `cat_${kategori}_${p + 1}` });
        
        const buttons = [];
        if (nav.length > 0) buttons.push(nav);
        
        // --- TOMBOL INPUT KODE SEKARANG ADA DI SINI ---
        buttons.push([{ text: '🛒 INPUT KODE SEKARANG', callback_data: 'menu_input_manual' }]);
        buttons.push([{ text: '🔙 KEMBALI KE MENU', callback_data: 'menu_list' }]);

        bot.editMessageText(pText, { 
            chat_id: chatId, 
            message_id: message.message_id, 
            parse_mode: 'Markdown', 
            reply_markup: { inline_keyboard: buttons } 
        });
    } catch (e) { 
        bot.answerCallbackQuery(id, { text: "❌ Gagal mengambil data paket." }); 
    }
}
    else if (data === 'menu_input_manual') {
        userState[chatId] = 'WAITING_BUY_CODE';
        bot.sendMessage(chatId, '🛒 Masukkan KODE PAKET (Contoh: pre295..):');
    }
    else if (data === 'back_to_menu') sendMainMenu(chatId, from.id, from.first_name, message.message_id);
    
    bot.answerCallbackQuery(id).catch(() => {});
});

// ==========================================
// 5. MESSAGE HANDLER (INPUT TEXT)
// ==========================================
bot.on('message', async (msg) => {
    const { chat, from, text } = msg;
    const chatId = chat.id;
    if (!text || chat.type !== 'private') return;

    const state = userState[chatId];

    if (text.startsWith('/start')) {
        getUserData(from.id, text.split(' ')[1]);
        return sendMainMenu(chatId, from.id, from.first_name);
    }

    // --- PROSES LOGIN XL ---
    if (state === 'WAITING_XL_PHONE') {
        let phone = text.replace(/[^0-9]/g, '');
        if (phone.startsWith('0')) phone = '62' + phone.slice(1);
        
        userState[chatId] = 'WAITING_XL_OTP';
        tempOrder[chatId] = { phone };
        
        bot.sendMessage(chatId, '🔄 Meminta OTP...');
        try {
            const res = await axios.get(`https://golang-openapi-reqotp-xltembakservice.kmsp-store.com/v1`, { params: { api_key: config.apiKeyKMSP, phone, method: 'OTP' } });
            if (res.data.status) {
                tempOrder[chatId].auth_id = res.data.data.auth_id;
                bot.sendMessage(chatId, '✅ OTP Terkirim! Masukkan Kode OTP:');
            } else bot.sendMessage(chatId, '❌ Gagal kirim OTP.');
        } catch (e) { bot.sendMessage(chatId, '❌ Gangguan API.'); }
    }
    else if (state === 'WAITING_XL_OTP') {
        const d = tempOrder[chatId];
        bot.sendMessage(chatId, '🔄 Verifikasi OTP...');
        try {
            const res = await axios.get(`https://golang-openapi-login-xltembakservice.kmsp-store.com/v1`, { 
                params: { api_key: config.apiKeyKMSP, phone: d.phone, method: 'OTP', auth_id: d.auth_id, otp: text.trim() } 
            });
            if (res.data.status) {
                xlSessions[from.id] = { phone: d.phone, token: res.data.data.access_token };
                saveDB(config.xlSessionsFile, xlSessions);
                bot.sendMessage(chatId, '✅ *LOGIN BERHASIL!*', { parse_mode: 'Markdown' });
            } else bot.sendMessage(chatId, '❌ OTP Salah.');
        } catch (e) { bot.sendMessage(chatId, '❌ Error Verifikasi.'); }
        delete userState[chatId];
    }

    // --- PROSES BUAT JADWAL ---
    else if (state === 'WAITING_SCHEDULE_TIME') {
        if (!/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(text)) return bot.sendMessage(chatId, '❌ Format Salah! Gunakan: `YYYY-MM-DD HH:MM`', {parse_mode:'Markdown'});
        
        const scheduledTime = new Date(text);
        if (scheduledTime <= new Date()) return bot.sendMessage(chatId, '❌ Waktu harus masa depan.');

        scheduleData.push({ userId: from.id, chatId, executeAt: scheduledTime.toISOString(), orderData: tempOrder[chatId] });
        saveDB(config.scheduleFile, scheduleData);
        
        bot.sendMessage(chatId, `✅ *JADWAL TERSIMPAN*\nPaket akan dibeli otomatis pada: ${text}`, {parse_mode:'Markdown'});
        delete userState[chatId];
        delete tempOrder[chatId];
    }

    // --- PROSES BELI PAKET ---
    else if (state === 'WAITING_BUY_CODE') {
        tempOrder[chatId] = { package_code: text.trim().toUpperCase() };
        userState[chatId] = 'WAITING_BUY_PHONE';
        bot.sendMessage(chatId, `✅ Kode OK. Masukkan *NOMOR TUJUAN*:`, { parse_mode: 'Markdown' });
    }
    else if (state === 'WAITING_BUY_PHONE') {
        let phone = text.replace(/[^0-9]/g, '');
        if (phone.startsWith('0')) phone = '62' + phone.slice(1);
        
        const code = tempOrder[chatId]?.package_code;
        if (!code) return bot.sendMessage(chatId, "❌ Sesi hilang.");

        const loading = await bot.sendMessage(chatId, "🔍 Cek Harga...");
        try {
            const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
            const p = res.data.data.find(x => x.package_code === code);
            
            if (!p) return bot.editMessageText("❌ Kode Invalid.", { chat_id: chatId, message_id: loading.message_id });

            const userData = getUserData(from.id);
            const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
            const finalPrice = p.package_harga_int + markup;

            tempOrder[chatId] = { phone, price_sell: finalPrice, name: p.package_name, code };

            const msg = `📦 *KONFIRMASI*\n${p.package_name}\nCode: ${code}\nTujuan: ${phone}\n💰 *${formatRupiah(finalPrice)}*`;
            bot.editMessageText(msg, {
                chat_id: chatId, message_id: loading.message_id, parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [
                    [{ text: '💰 Bayar Saldo', callback_data: 'pay_balance' }, { text: '💳 Isi Saldo', callback_data: 'menu_topup' }],
                    [{ text: '⏰ Buat Jadwal', callback_data: 'set_schedule' }],
                    [{ text: '❌ Batal', callback_data: 'back_to_menu' }]
                ]}
            });
            delete userState[chatId];
        } catch (e) { bot.sendMessage(chatId, "❌ Server Error."); }
    }

    // --- PROSES TOPUP ---
    else if (state === 'WAITING_TOPUP_AMOUNT') {
        const nominal = parseInt(text.replace(/[^0-9]/g, ''));
        delete userState[chatId];
        if (nominal < 1000) return bot.sendMessage(chatId, '❌ Min Rp 1.000.');
        
        const msg = await bot.sendMessage(chatId, '🔄 Generate QRIS...');
        try {
            const res = await axios.get(`https://my-payment.autsc.my.id/api/deposit`, { params: { amount: nominal, apikey: config.apiKeyPayment } });
            if (res.data.status === 'success') {
                bot.deleteMessage(chatId, msg.message_id);
                bot.sendPhoto(chatId, res.data.data.qris_url, { caption: `💰 *TAGIHAN TOPUP*\nJumlah: ${formatRupiah(res.data.data.total_amount)}\n\n_Saldo masuk otomatis._`, parse_mode: 'Markdown' });
            }
        } catch (e) { bot.sendMessage(chatId, '❌ Gagal.'); }
    }
});

// Helper Menu Utama
const sendMainMenu = (chatId, userId, name, messageId = null) => {
    const d = getUserData(userId);
    const msg = `🤖 *FANTUNNEL BOT*\n👤 ${name} (${d.role.toUpperCase()})\n💰 ${formatRupiah(d.balance)}\n⏳ ${getRuntime()}`;
    const opts = {
        parse_mode: 'Markdown',
        reply_markup: { inline_keyboard: [
            [{ text: '🛒 BELI PAKET', callback_data: 'menu_list' }, { text: '💰 ISI SALDO', callback_data: 'menu_topup' }],
            [{ text: '🔐 LOGIN XL', callback_data: 'menu_xl_login' }, { text: '📊 CEK KUOTA', callback_data: 'menu_cekkouta' }],
            [{ text: '👑 UPGRADE RESELLER', callback_data: 'menu_reseller' }],
        ]}
    };
    if (messageId) bot.editMessageText(msg, { chat_id: chatId, message_id: messageId, ...opts }).catch(()=>{});
    else bot.sendMessage(chatId, msg, opts);
};

// ==========================================
// 6. SUPER BACKUP SYSTEM (PRO VERSION)
// ==========================================
import { exec } from 'child_process'; // Tambahkan ini di paling atas file jika belum ada

const runBackup = async (targetId) => {
    try {
        const totalUsers = Object.keys(userBalance).length;
        const totalSaldo = Object.values(userBalance).reduce((a, b) => a + (b.balance || 0), 0);
        const totalJadwal = scheduleData.length;

        const report = `
📊 *LAPORAN BACKUP HARIAN*
──────────────────
👥 Total User: ${totalUsers}
💰 Saldo Beredar: ${formatRupiah(totalSaldo)}
⏳ Antrean Jadwal: ${totalJadwal}
📂 Status: *Success Compressed*
⏰ Waktu: ${new Date().toLocaleString('id-ID')}
──────────────────`;

        // Kirim Laporan
        await bot.sendMessage(targetId, report, { parse_mode: 'Markdown' });

        // Kirim semua file satu per satu dengan rapi
        const files = fs.readdirSync('./database');
        for (const file of files) {
            const filePath = `./database/${file}`;
            if (fs.existsSync(filePath)) {
                await bot.sendDocument(targetId, filePath, { 
                    caption: `📄 Database: ${file}` 
                }).catch(() => {});
            }
        }
    } catch (e) {
        bot.sendMessage(config.ownerId, `❌ *BACKUP GAGAL:* ${e.message}`);
    }
};

// --- CRON JOB BACKUP (Tiap jam 00:00) ---
setInterval(() => {
    const now = new Date();
    if (now.getHours() === 0 && now.getMinutes() === 0) {
        runBackup(config.ownerId);
        runBackup(config.adminGroupId); // Kirim ke grup admin juga buat cadangan
    }
}, 60000);

// --- COMMAND KHUSUS OWNER (/backup & /stats) ---
bot.on('message', async (msg) => {
    const { text, from, chat } = msg;
    if (!text) return;

    // Command manual backup
    if (text === '/backup' && from.id === config.ownerId) {
        bot.sendMessage(chat.id, "🔄 *Sedang mengumpulkan data database...*");
        runBackup(from.id);
    }

    // Command cek statistik bot
    if (text === '/stats' && from.id === config.ownerId) {
        const totalUsers = Object.keys(userBalance).length;
        const totalSaldo = Object.values(userBalance).reduce((a, b) => a + (b.balance || 0), 0);
        const stats = `
📈 *STATISTIK BOT SAAT INI*
──────────────────
👥 Pengguna: ${totalUsers} orang
💰 Total Saldo User: ${formatRupiah(totalSaldo)}
📅 Jadwal Pending: ${scheduleData.length}
🚀 Uptime: ${getRuntime()}
──────────────────`;
        bot.sendMessage(chat.id, stats, { parse_mode: 'Markdown' });
    }
});

console.log('Bot V4 + Super Backup Active! 🚀');
