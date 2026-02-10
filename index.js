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
    userBalanceFile: "./database/user_balance.json", 
    historyFile: "./database/history.json",
    xlSessionsFile: "./database/xl_sessions.json",
    apiKeyKMSP: "29dc3989-2394-448d-a7a5-8a6c3fa59f5d", 
    apiKeyPayment: "e435777e-47ed-4485-a06c-767dbe895d1f", 
    sidompulAuth: "Basic c2lkb21wdWxhcGk6YXBpZ3drbXNw",
    sidompulKey: "60ef29aa-a648-4668-90ae-20951ef90c55", 
    markupMember: 3000,   
    markupReseller: 1000,
    priceUpgradeReseller: 10000,
    bonusReferralUpgrade: 2000
};

const botStartTime = Date.now();
const bot = new TelegramBot(config.token, { polling: true });

// ==========================================
// 2. DATABASE HANDLER
// ==========================================
if (!fs.existsSync('./database')) fs.mkdirSync('./database');
const loadDB = (file, defaultVal) => {
let xlSessions = loadDB(config.xlSessionsFile, {});
    try {
        if (!fs.existsSync(file)) {
            fs.writeFileSync(file, JSON.stringify(defaultVal, null, 2));
            return defaultVal;
        }
        return JSON.parse(fs.readFileSync(file));
    } catch (e) { return defaultVal; }
};
const saveDB = (file, data) => fs.writeFileSync(file, JSON.stringify(data, null, 2));

let userBalance = loadDB(config.userBalanceFile, {}); 
let historyTrx = loadDB(config.historyFile, []);

const userState = {}; 
const tempOrder = {}; 
const isProcessing = {}; // Untuk mengunci transaksi yang sedang berjalan

const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

const getUserData = (userId, referrerId = null) => {
    if (!userBalance[userId]) {
        userBalance[userId] = { 
            balance: 0, 
            role: 'member',
            referredBy: (referrerId && referrerId != userId) ? referrerId : null 
        };
        saveDB(config.userBalanceFile, userBalance);
    }
    return userBalance[userId];
};

const getRuntime = () => {
    const uptime = Date.now() - botStartTime;
    const seconds = Math.floor((uptime / 1000) % 60);
    const minutes = Math.floor((uptime / (1000 * 60)) % 60);
    const hours = Math.floor((uptime / (1000 * 60 * 60)) % 24);
    const days = Math.floor(uptime / (1000 * 60 * 60 * 24));
    return `${days}h ${hours}j ${minutes}m ${seconds}d`;
};

// ==========================================
// UPDATE TAMPILAN DASHBOARD (SIMPLE VERSION)
// ==========================================
const sendMainMenu = async (chatId, userId, name, messageId = null) => {
    const userData = getUserData(userId);
    const totalUsers = Object.keys(userBalance).length;
    
    // FIX PERHITUNGAN TRX
    let day = 0, month = 0, total = 0;
    const tgl = new Date().toLocaleDateString('id-ID');
    const bln = (new Date().getMonth() + 1) + "-" + new Date().getFullYear();
    
    historyTrx.forEach(t => {
        // Kita gunakan t.price karena di confirm_buy kamu simpan sebagai .price
        const nilaiTrx = t.price || 0; 
        total += nilaiTrx;
        
        const d = new Date(t.date);
        if (d.toLocaleDateString('id-ID') === tgl) day += nilaiTrx;
        if (((d.getMonth() + 1) + "-" + d.getFullYear()) === bln) month += nilaiTrx;
    });

    // FIX FORMAT TEBAL (Menambahkan spasi setelah emoji agar Markdown tidak error)
    const menuMsg = `
┏━━━━━━━━━━━━━━━━━━━┓
┃            ✨ *WELCOME* ✨            ┃
┗━━━━━━━━━━━━━━━━━━━┛
๑⚙️๑ *${name}*
───────────────────
👤 *Role* : ${userData.role.toUpperCase()}
💰 *Saldo* : ${formatRupiah(userData.balance)}
⏳ *Runtime* : ${getRuntime()}
───────────────────
📊 *Stats Bot:*
👥 User: ${totalUsers} | 🌍 TRX: ${formatRupiah(total)}
───────────────────
☀️ [ADMIN](https://t.me/AJW29) ☀️ [GRUP](https://t.me/klmpkfsvpn) ☀️ [LOG TRX](https://t.me/klmpkfsvpn/1)`; 

    const opts = {
        parse_mode: 'Markdown',
        disable_web_page_preview: true, // Agar link tidak muncul preview besar
        reply_markup: {
            inline_keyboard: [
                [{ text: 'MENU', callback_data: 'menu_semua_fitur' }],
            ]
        }
    };

    if (messageId) return bot.editMessageText(menuMsg, { chat_id: chatId, message_id: messageId, ...opts }).catch(()=>{});
    bot.sendMessage(chatId, menuMsg, opts);
};

// ==========================================
// CALLBACK UNTUK MENU SATU KESATUAN
// ==========================================
bot.on('callback_query', async (clb) => {
    const chatId = clb.message.chat.id;
    const userId = clb.from.id;
    const data = clb.data;
    const userData = getUserData(userId);

    try {
    // Tambahkan logika ini di dalam bot.on('callback_query')
    if (data === 'menu_semua_fitur') {
        const featureOpts = {
            chat_id: chatId,
            message_id: clb.message.message_id,
            parse_mode: 'Markdown',
            reply_markup: {
                inline_keyboard: [
                    [{ text: '🛒 Beli Paket', callback_data: 'menu_beli' }, { text: '💰 Isi Saldo', callback_data: 'menu_topup' }],
                [{ text: '🔍 Cek Kuota', callback_data: 'menu_cekkouta' }, { text: '📜 Riwayat', callback_data: 'menu_history' }],
                [{ text: '🔐 Login XL', callback_data: 'menu_xl_login' }, { text: '📊 Info XL', callback_data: 'menu_xl_info' }],
                [{ text: '👑 Upgrade Reseller', callback_data: 'menu_reseller' }, { text: '📦 List Paket', callback_data: 'menu_list' }],
                [{ text: '👨‍👩‍👧‍👦 Cek Akrab', callback_data: 'menu_cek_akrab' }, { text: '🎁 Referral', callback_data: 'menu_referral' }],
                [{ text: '👤 Owner', callback_data: 'menu_owner' }]
            ]
        }
    };
        return bot.editMessageText("🛠️ *PUSAT FITUR FANTUNNEL*\nSilakan pilih fitur yang ingin digunakan:", featureOpts);
    }
    
    // Callback lainnya (back_to_menu, menu_referral, dll tetap sama)
});

// ==========================================
// 3. CALLBACK HANDLER
// ==========================================
bot.on('callback_query', async (callback) => {
    const chatId = callback.message.chat.id;
    const userId = callback.from.id;
    const data = callback.data;
    const userData = getUserData(userId);

    try {
        if (data === 'menu_beli') {
            userState[chatId] = 'WAITING_BUY_CODE';
            await bot.sendMessage(chatId, '🛒 *BELI PAKET*\nKirimkan *KODE PAKET*:');
        } 
        else if (data === 'menu_list') {
            await bot.sendMessage(chatId, '📂 *PILIH KATEGORI PAKET*:', {
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '💎 BEST SELLER VPN', callback_data: 'cat_bestseller' }],
                        [{ text: '👨‍👩‍👧‍👦 XL AKRAB', callback_data: 'cat_akrab' }, { text: '⚡ XTRA COMBO', callback_data: 'cat_combo' }],
                        [{ text: '🔥 XTRA HOTROD', callback_data: 'cat_hotrod' }, { text: '🌐 LAINNYA', callback_data: 'cat_all' }],
                        [{ text: '💰 DAFTAR HARGA KHUSUS', callback_data: 'cek_price_list' }],
                        [{ text: '🔙 KEMBALI', callback_data: 'back_to_menu' }]
                    ]
                },
                parse_mode: 'Markdown'
            });
        }
        else if (data.startsWith('cat_')) {
            const params = data.split('_');
            const kategori = params[1];
            const page = parseInt(params[2]) || 0;
            const itemsPerPage = 10;

            try {
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                if (res.data && res.data.data) {
                    let allData = res.data.data;
                    let filtered = [];

                    if (kategori === 'bestseller') {
                        filtered = allData.filter(p => /edukasi|conference|iflix|xtra kuota/i.test(p.package_name));
                    } else if (kategori === 'akrab') {
                        filtered = allData.filter(p => p.package_name.toLowerCase().includes('akrab'));
                    } else if (kategori === 'combo') {
                        filtered = allData.filter(p => p.package_name.toLowerCase().includes('combo'));
                    } else if (kategori === 'hotrod') {
                        filtered = allData.filter(p => p.package_name.toLowerCase().includes('hotrod') || p.package_name.toLowerCase().includes('xtra hot'));
                    } else {
                        filtered = allData.filter(p => !/akrab|combo|hotrod|edukasi|conference|iflix/i.test(p.package_name));
                    }

                    if (filtered.length === 0) return bot.sendMessage(chatId, "❌ Paket tidak tersedia.");

                    const totalPages = Math.ceil(filtered.length / itemsPerPage);
                    const start = page * itemsPerPage;
                    const paginatedItems = filtered.slice(start, start + itemsPerPage);

                    let pText = `📦 *LIST PAKET: ${kategori.toUpperCase()}*\n`;
                    pText += `📖 Halaman: *${page + 1} / ${totalPages}*\n\n`;

                    const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                    
                    paginatedItems.forEach((p) => {
                        const hargaJual = p.package_harga_int + markup;
                        pText += `🔹 *${p.package_name}*\n` +
                                 `   Kode: \`${p.package_code}\`\n` +
                                 `   Harga: *${formatRupiah(hargaJual)}*\n\n`;
                    });

                    const navButtons = [];
                    if (page > 0) navButtons.push({ text: '⬅️ Prev', callback_data: `cat_${kategori}_${page - 1}` });
                    if (start + itemsPerPage < filtered.length) navButtons.push({ text: 'Next ➡️', callback_data: `cat_${kategori}_${page + 1}` });

                    await bot.editMessageText(pText, {
                        chat_id: chatId,
                        message_id: callback.message.message_id,
                        parse_mode: 'Markdown',
                        reply_markup: { 
                            inline_keyboard: [ navButtons, [{ text: '🔙 KATEGORI', callback_data: 'menu_list' }], [{ text: '🏠 MENU', callback_data: 'back_to_menu' }] ] 
                        }
                    }).catch(() => {});
                }
            } catch (e) { bot.sendMessage(chatId, "❌ Gagal memuat data."); }
        }
        else if (data === 'cek_price_list') {
            await bot.answerCallbackQuery(callback.id);
            try {
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                let pText = `💰 *HARGA KHUSUS ${userData.role.toUpperCase()}*\n━━━━━━━━━━━━━━\n`;
                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                res.data.data.slice(0, 15).forEach(p => {
                    pText += `▪️ ${p.package_name}\n   └ *${formatRupiah(p.package_harga_int + markup)}*\n`;
                });
                bot.sendMessage(chatId, pText, { parse_mode: 'Markdown' });
            } catch (e) { bot.sendMessage(chatId, "❌ Gagal."); }
        }
        else if (data === 'menu_cek_akrab') {
            userState[chatId] = 'WAITING_CEK_AKRAB';
            await bot.sendMessage(chatId, '👨‍👩‍👧‍👦 *CEK AKRAB*\nMasukkan nomor XL pengelola:');
        }
        else if (data === 'menu_topup') {
            userState[chatId] = 'WAITING_TOPUP_AMOUNT';
            await bot.sendMessage(chatId, '💰 *ISI SALDO*\nMasukkan nominal (Min. 1000):');
        }
        else if (data === 'menu_cekkouta') {
            userState[chatId] = 'WAITING_CHECK_QUOTA';
            await bot.sendMessage(chatId, '🔍 *CEK KUOTA*\nKirim nomor XL (08xx):');
        }
        else if (data === 'menu_history') {
            const myHistory = historyTrx.filter(h => h.userId === userId).slice(-5);
            if (myHistory.length === 0) return bot.sendMessage(chatId, "📜 Belum ada transaksi.");
            let hText = "📜 *RIWAYAT TERAKHIR*\n\n";
            myHistory.forEach((h, i) => { hText += `${i+1}. ${h.product}\n   Status: ${h.status} | ${formatRupiah(h.price)}\n\n`; });
            await bot.sendMessage(chatId, hText, { parse_mode: 'Markdown' });
        }
        else if (data === 'menu_xl_login') {
            userState[chatId] = 'WAITING_XL_PHONE';
            await bot.sendMessage(chatId, '🔐 *LOGIN XL*\n\nKirim Nomor XL kamu untuk minta OTP.\nContoh: `0878xxxx`', { parse_mode: 'Markdown' });
        }
        else if (data === 'menu_xl_info') {
            if (!xlSessions[userId]) return bot.sendMessage(chatId, '❌ Belum login. Pilih menu Login XL dulu.');
            await bot.sendMessage(chatId, '⏳ Cek Paket...');
            try {
                const res = await axios.get(`https://golang-openapi-quotadetails-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, access_token: xlSessions[userId].access_token }
                });
                if (res.data.status) {
                    let t = `📊 *PAKET AKTIF*\nNO: ${res.data.data.msisdn}\n\n`;
                    res.data.data.quotas.forEach((q, i) => {
                        t += `*${i+1}. ${q.name}*\nExp: ${q.expired_at}\n\n`;
                    });
                    await bot.sendMessage(chatId, t, { parse_mode: 'Markdown' });
                } else {
                    await bot.sendMessage(chatId, `❌ Gagal/Sesi Habis: ${res.data.message}`);
                }
            } catch (e) { await bot.sendMessage(chatId, '❌ Error API.'); }
        }
        else if (data === 'menu_referral') {
            const link = `https://t.me/${config.botUsername}?start=${userId}`;
            await bot.sendMessage(chatId, 
                `🎁 *PROGRAM REFERRAL*\n\n` +
                `Dapatkan bonus saldo sebesar *${formatRupiah(config.bonusReferralUpgrade)}* setiap kali teman yang kamu ajak melakukan *Upgrade Reseller*.\n\n` +
                `🔗 *Link Referral Kamu:* \n\`${link}\`\n\n` +
                `Bagikan link di atas ke teman-temanmu!`, 
                { parse_mode: 'Markdown' }
            );
        }
        else if (data === 'menu_reseller') {
            if (userData.role === 'reseller') return bot.sendMessage(chatId, "✅ Kamu sudah menjadi Reseller.");
            await bot.sendMessage(chatId, `👑 *UPGRADE RESELLER*\n\nBiaya: *${formatRupiah(config.priceUpgradeReseller)}*\n\nPotongan harga (Markup) per transaksi hanya Rp ${config.markupReseller}!`, {
                reply_markup: { inline_keyboard: [[{ text: '✅ SETUJU & UPGRADE', callback_data: 'confirm_upgrade' }], [{ text: '❌ BATAL', callback_data: 'back_to_menu' }]] },
                parse_mode: 'Markdown'
            });
        }
        else if (data === 'check_payment') {
            const order = tempOrder[chatId];
            if (!order || order.type !== 'topup') return bot.sendMessage(chatId, '❌ Data transaksi hilang/kadaluwarsa.');
            
            await bot.sendMessage(chatId, '🔍 Cek mutasi...');
            try {
                const res = await axios.get(`https://my-payment.autsc.my.id/api/status/payment`, {
                    params: { transaction_id: order.trx_id, apikey: config.apiKeyPayment }
                });
                if (res.data.paid) {
                    if (!userBalance[userId]) userBalance[userId] = 0;
                    userBalance[userId] += order.amount_added;
                    saveDB(config.userBalanceFile, userBalance);
                    
                    delete tempOrder[chatId];
                    await bot.sendMessage(chatId, `✅ *TOPUP SUKSES!*\nSaldo Masuk: ${formatRupiah(order.amount_added)}`);
                } else {
                    await bot.sendMessage(chatId, '❌ Pembayaran belum masuk. Coba lagi nanti.');
                }
            } catch (e) { await bot.sendMessage(chatId, '❌ Gagal cek status.'); }
        }
        else if (data === 'confirm_upgrade') {
            if (userData.balance < config.priceUpgradeReseller) {
                return bot.sendMessage(chatId, "❌ Saldo tidak cukup untuk upgrade.");
            }
            
            // Proses Potong Saldo & Ganti Role
            userBalance[userId].balance -= config.priceUpgradeReseller;
            userBalance[userId].role = 'reseller';

            // CEK REFERRAL: Jika user ini diajak seseorang
            if (userData.referredBy && userBalance[userData.referredBy]) {
                const bonus = config.bonusReferralUpgrade;
                userBalance[userData.referredBy].balance += bonus;
                
                // Beri notif ke pengajak
                bot.sendMessage(userData.referredBy, 
                    `💰 *BONUS MASUK!*\nTeman yang kamu ajak baru saja upgrade Reseller. Saldo kamu bertambah *${formatRupiah(bonus)}*`
                );
            }

            saveDB(config.userBalanceFile, userBalance);
            await bot.sendMessage(chat_id, "🎉 *SELAMAT!*\nKamu sekarang adalah Reseller. Harga paket otomatis menjadi lebih murah!");
        }
        else if (data === 'menu_owner') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "❌ Akses Ditolak" });
            
            const ownerOpts = {
                chat_id: chatId,
                message_id: callback.message.message_id,
                parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '➕ Tambah Saldo User', callback_data: 'owner_add_saldo' }],
                        [{ text: '📢 Broadcast Pesan', callback_data: 'owner_broadcast' }],
                        [{ text: '💰 Dashboard Profit', callback_data: 'owner_cek_profit' }],
                        [{ text: '🎭 Ubah Role User', callback_data: 'owner_set_role' }],
                        [{ text: '🏠 Kembali', callback_data: 'back_to_menu' }]
                    ]
                }
            };
            await bot.editMessageText("👑 *OWNER DASHBOARD*\nKelola bisnis kamu di sini:", ownerOpts);
        }
// --- PROSES TAMBAH SALDO BY OWNER ---
        else if (state === 'OWNER_WAITING_ID_ADD') {
            const targetId = text.trim();
            if (!userBalance[targetId]) return bot.sendMessage(chatId, "❌ ID tidak terdaftar di database.");
            tempOrder[chatId] = { targetId }; // Simpan ID sementara
            userState[chatId] = 'OWNER_WAITING_AMOUNT_ADD';
            await bot.sendMessage(chatId, `👤 User: ${targetId}\n💰 Masukkan nominal saldo:`);
        }
        else if (state === 'OWNER_WAITING_AMOUNT_ADD') {
            const amount = parseInt(text.replace(/[^0-9]/g, ''));
            const targetId = tempOrder[chatId].targetId;
            
            userBalance[targetId].balance += amount;
            saveDB(config.userBalanceFile, userBalance);
            
            delete userState[chatId];
            delete tempOrder[chatId];
            
            await bot.sendMessage(chatId, `✅ Berhasil menambah *${formatRupiah(amount)}* ke ID \`${targetId}\``, { parse_mode: 'Markdown' });
            // Notif ke User
            bot.sendMessage(targetId, `🎁 *SALDO MASUK!*\nOwner telah menambahkan saldo sebesar *${formatRupiah(amount)}* ke akunmu.`, { parse_mode: 'Markdown' });
        }

        // --- PROSES UBAH ROLE BY OWNER ---
        else if (state === 'OWNER_WAITING_ID_ROLE') {
            const targetId = text.trim();
            if (!userBalance[targetId]) return bot.sendMessage(chatId, "❌ ID tidak terdaftar.");
            
            await bot.sendMessage(chatId, `🎭 Pilih Role baru untuk \`${targetId}\`:`, {
                reply_markup: {
                    inline_keyboard: [
                        [{ text: 'Member', callback_data: `setrole_${targetId}_member` }, { text: 'Reseller', callback_data: `setrole_${targetId}_reseller` }]
                    ]
                }
            });
            delete userState[chatId];
        }
        else if (data === 'owner_broadcast') {
            userState[chatId] = 'OWNER_WAITING_BC_TEXT';
            await bot.sendMessage(chatId, '📢 *BROADCAST MODE*\n\nSilakan kirim pesan yang ingin disebarkan ke semua user.\n_(Bisa menggunakan Markdown seperti *tebal* atau _miring_)_');
        }
        else if (data === 'owner_cek_profit') {
            let profitDay = 0, profitMonth = 0, profitTotal = 0;
            const tglSekarang = new Date().toLocaleDateString('id-ID');
            const blnSekarang = (new Date().getMonth() + 1) + "-" + new Date().getFullYear();

            historyTrx.forEach(t => {
                if (t.status === 'SUKSES') {
                    const untung = t.profit || 0; 
                    const d = new Date(t.date);
                    const tglTrx = d.toLocaleDateString('id-ID');
                    const blnTrx = (d.getMonth() + 1) + "-" + d.getFullYear();

                    profitTotal += untung;
                    if (tglTrx === tglSekarang) profitDay += untung;
                    if (blnTrx === blnSekarang) profitMonth += untung;
                }
            });

            const profitMsg = `
📊 *DASHBOARD KEUNTUNGAN*
━━━━━━━━━━━━━━━━━━━
💰 *Hari Ini:* ${formatRupiah(profitDay)}
📅 *Bulan Ini:* ${formatRupiah(profitMonth)}
🏆 *Total Profit:* ${formatRupiah(profitTotal)}
━━━━━━━━━━━━━━━━━━━
📈 *Statistik Bot:*
🛒 Total TRX Sukses: ${historyTrx.filter(x => x.status === 'SUKSES').length}
👥 Total User: ${Object.keys(userBalance).length}
━━━━━━━━━━━━━━━━━━━`;

            await bot.editMessageText(profitMsg, {
                chat_id: chatId,
                message_id: callback.message.message_id,
                parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [[{ text: '🔙 Kembali', callback_data: 'menu_owner' }]]
                }
            });
        }
        else if (data === 'confirm_buy') {
            const order = tempOrder[chatId];
            
            // 1. CEK APAKAH SEDANG ADA PROSES BERJALAN
            if (isProcessing[chatId]) {
                return bot.answerCallbackQuery(callback.id, { text: "⚠️ Transaksi sedang diproses, mohon tunggu!", show_alert: true });
            }

            if (!order || userData.balance < order.price_sell) {
                return bot.sendMessage(chatId, '❌ Saldo tidak cukup atau data hilang.');
            }

            // 2. KUNCI TRANSAKSI
            isProcessing[chatId] = true;
            
            // Potong saldo di awal (Safety First)
            userBalance[userId].balance -= order.price_sell;
            saveDB(config.userBalanceFile, userBalance);
            
            await bot.sendMessage(chatId, '🚀 *Sedang Memproses ke Provider...*\nMohon jangan tekan tombol apapun.', { parse_mode: 'Markdown' });

            try {
                const res = await axios.get(`https://golang-openapi-packagepurchase-xltembakservice.kmsp-store.com/v1`, {
                    params: { 
                        api_key: config.apiKeyKMSP, 
                        package_code: order.package_code, 
                        phone: order.phone, 
                        price_or_fee: order.price_server 
                    },
                    timeout: 60000 // Limit tunggu 60 detik
                });

                if (res.data.status) {
                    // BERHASIL
                    // HITUNG PROFIT
                    const profitTrx = order.price_sell - order.price_server;

                    historyTrx.push({ 
                        date: new Date(), 
                        userId, 
                        product: order.name, 
                        price: order.price_sell, 
                        profit: profitTrx, // <--- TAMBAHKAN INI
                        status: 'SUKSES' 
                    });
                    saveDB(config.historyFile, historyTrx);
                    
                    await bot.sendMessage(chatId, `✅ *TRANSAKSI BERHASIL!*\n\nProduk: ${order.name}\nNomor: ${order.phone}\nSisa Saldo: ${formatRupiah(userBalance[userId].balance)}`, { parse_mode: 'Markdown' });
                } else {
                    // GAGAL DARI PROVIDER -> REFUND
                    userBalance[userId].balance += order.price_sell;
                    saveDB(config.userBalanceFile, userBalance);
                    await bot.sendMessage(chatId, `❌ *GAGAL:* ${res.data.message}\nSaldo telah dikembalikan.`);
                }
            } catch (e) {
                // ERROR SISTEM/TIMEOUT -> REFUND
                userBalance[userId].balance += order.price_sell;
                saveDB(config.userBalanceFile, userBalance);
                bot.sendMessage(chatId, '❌ *Koneksi Timeout/Gangguan Provider.*\nSaldo otomatis di-refund.');
                
                // Laporan ke Owner
                bot.sendMessage(config.ownerId, `⚠️ *ALARM:* Transaksi Gagal/Timeout\nUser: ${userId}\nProduk: ${order.package_code}`);
            } finally {
                // 3. BUKA KUNCI TRANSAKSI
                delete isProcessing[chatId];
                delete tempOrder[chatId];
            }
        }
        else if (data === 'back_to_menu') {
            delete userState[chatId];
            await sendMainMenu(chatId, userId, callback.from.first_name, callback.message.message_id);
        }
    } catch (e) { console.error(e); }
    bot.answerCallbackQuery(callback.id).catch(() => {});
});

// ==========================================
// 4. MESSAGE HANDLER (DENGAN FIX REFERRAL)
// ==========================================
bot.on('message', async (msg) => {
    const chatId = msg.chat.id;
    const userId = msg.from.id;
    const text = msg.text;

    // 1. FILTER: Abaikan jika bukan chat pribadi (biar gak berisik di grup)
    if (msg.chat.type !== 'private') return;

    // 2. FILTER: Abaikan jika yang dikirim bukan teks (stiker/foto)
    if (!text) return;

    // 3. LOGIKA PERINTAH / (SLASH)
    if (text.startsWith('/')) {
        
        // --- Handle /start ---
        if (text.startsWith('/start')) {
            const parts = text.split(' ');
            const referrerId = parts.length > 1 ? parts[1] : null;
            
            getUserData(userId, referrerId); 
            return sendMainMenu(chatId, userId, msg.from.first_name);
        }

        // --- Handle /backup (Khusus Owner) ---
        if (text.startsWith('/backup')) {
            if (userId !== config.ownerId) return;
            // Panggil fungsi runBackup yang sudah kita buat tadi
            return runBackup(config.ownerId); 
        }

        // Jika ada command / lain tapi tidak terdaftar, biarkan saja
        return; 
    }

    // 4. LOGIKA STATE (INPUT BIASA)
    const state = userState[chatId];
    const userData = getUserData(userId);

    try {
        if (state === 'WAITING_BUY_CODE') {
            tempOrder[chatId] = { package_code: text.toUpperCase().trim() };
            userState[chatId] = 'WAITING_BUY_PHONE';
            await bot.sendMessage(chatId, `✅ Kode: ${text.toUpperCase()}\nKirim *NOMOR TUJUAN (08xxx)*:`);
        }
        else if (state === 'WAITING_BUY_PHONE') {
            let phone = text.replace(/[^0-9]/g, '');
            if (phone.startsWith('08')) phone = '62' + phone.slice(1);
            
            const code = tempOrder[chatId].package_code;
            await bot.sendMessage(chatId, '⏳ Mengecek paket...');
            
            try {
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                const p = res.data.data.find(x => x.package_code === code);
                
                if (!p) {
                    delete userState[chatId];
                    return bot.sendMessage(chatId, '❌ Paket tidak ditemukan.');
                }

                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                const finalPrice = p.package_harga_int + markup;

                tempOrder[chatId] = { ...tempOrder[chatId], phone, price_server: p.package_harga_int, price_sell: finalPrice, name: p.package_name };
                delete userState[chatId];

                await bot.sendMessage(chatId, `📦 *KONFIRMASI*\n\nProduk: ${p.package_name}\nNomor: ${phone}\nHarga: *${formatRupiah(finalPrice)}*\n\nLanjutkan?`, {
                    parse_mode: 'Markdown',
                    reply_markup: { inline_keyboard: [[{ text: '✅ BELI', callback_data: 'confirm_buy' }], [{ text: '❌ BATAL', callback_data: 'back_to_menu' }]] }
                });
            } catch (e) { bot.sendMessage(chatId, '❌ Error API.'); }
        }
// --- ALUR CEK KUOTA & TOPUP ---
        else if (state === 'WAITING_CHECK_QUOTA') {
            let phone = text.replace(/[^0-9]/g, '');
            if (phone.startsWith('08')) phone = '62' + phone.slice(1);
            delete userState[chatId];
            await bot.sendMessage(chatId, '🔍 Sedang mengecek kuota...');
            try {
                const res = await axios.get(`https://apigw.kmsp-store.com/sidompul/v4/cek_kuota`, { 
                    params: { msisdn: phone, isJSON: 'true' }, 
                    headers: { "Authorization": config.sidompulAuth, "X-API-Key": config.sidompulKey, "X-App-Version": "4.0.0" } 
                });
                if (res.data.status && res.data.data.hasil) {
                    await bot.sendMessage(chatId, res.data.data.hasil.replace(/<br>/g, "\n").replace(/📃 RESULT:/g, "📊 *HASIL CEK KUOTA*"), { parse_mode: 'Markdown' });
                } else {
                    await bot.sendMessage(chatId, '❌ Data tidak ditemukan atau nomor salah.');
                }
            } catch(e) { bot.sendMessage(chatId, '❌ Terjadi gangguan pada provider.'); }
        }
        // 3. ALUR LOGIN XL (REQUEST OTP)
        else if (state === 'WAITING_XL_PHONE') {
            let phone = text.replace(/[^0-9]/g, '');
            if (phone.startsWith('0')) phone = '62' + phone.slice(1);
            await bot.sendMessage(chatId, '⏳ Request OTP...');
            try {
                const res = await axios.get(`https://golang-openapi-reqotp-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, phone: phone, method: 'OTP' }
                });
                if (res.data.status) {
                    userState[chatId] = 'WAITING_XL_OTP';
                    // PENTING: auth_id disimpan di sini agar bisa dipakai di step verifikasi
                    tempOrder[chatId] = { auth_id: res.data.data.auth_id, phone: phone };
                    await bot.sendMessage(chatId, '✅ OTP Terkirim! Silakan balas dengan *Kode OTP*:');
                } else {
                    delete userState[chatId];
                    await bot.sendMessage(chatId, `❌ Gagal: ${res.data.message}`);
                }
            } catch (e) { bot.sendMessage(chatId, '❌ Error API Request OTP.'); }
        }

        // 4. ALUR VERIFIKASI OTP (VERSI ANTI-RIBET)
        else if (state === 'WAITING_XL_OTP') {
            const otp = text.trim();
            const dataLogin = tempOrder[chatId];

            if (!dataLogin || !dataLogin.auth_id) {
                delete userState[chatId];
                return bot.sendMessage(chatId, '❌ Sesi hilang. Silakan ulangi login.');
            }

            await bot.sendMessage(chatId, '⏳ Memverifikasi OTP...');
            try {
                const res = await axios.get(`https://golang-openapi-login-xltembakservice.kmsp-store.com/v1`, {
                    params: {
                        api_key: config.apiKeyKMSP,
                        phone: dataLogin.phone,
                        method: 'OTP',
                        auth_id: dataLogin.auth_id,
                        otp: otp
                    }
                });

                if (res.data.status) {
                    xlSessions[userId] = { phone: dataLogin.phone, access_token: res.data.data.access_token };
                    saveDB(config.xlSessionsFile, xlSessions);
                    delete userState[chatId];
                    delete tempOrder[chatId];
                    await bot.sendMessage(chatId, '✅ *LOGIN BERHASIL!*', { parse_mode: 'Markdown' });
                } else {
                    // Jika OTP salah atau kadaluwarsa
                    await bot.sendMessage(chatId, `❌ Gagal: ${res.data.message || 'OTP tidak valid'}`);
                }
            } catch (e) {
                // LOGIKA ANTI-RIBET: Kirim detail error ke Owner agar kamu tahu masalahnya
                const errorDetail = e.response?.data?.message || e.message;
                const errorStatus = e.response?.status || 'No Status';
                
                // Pesan untuk User
                bot.sendMessage(chatId, `❌ Terjadi gangguan server. Admin telah dinotifikasi.`);
                
                // Pesan untuk Kamu (Owner)
                bot.sendMessage(config.ownerId, 
                    `⚠️ *LOG ERROR VERIFIKASI*\n\n` +
                    `User: ${userId}\n` +
                    `HP: ${dataLogin.phone}\n` +
                    `Error: ${errorDetail}\n` +
                    `HTTP Status: ${errorStatus}`, 
                { parse_mode: 'Markdown' });
            }
        }
        else if (state === 'WAITING_TOPUP_AMOUNT') {
            const nominal = parseInt(text.replace(/[^0-9]/g, ''));
            if (isNaN(nominal) || nominal < 1000) return bot.sendMessage(chatId, '❌ Minimal Rp 1.000.');
            delete userState[chatId];
            try {
                const res = await axios.get(`https://my-payment.autsc.my.id/api/deposit`, { params: { amount: nominal, apikey: config.apiKeyPayment } });
                if (res.data.status === 'success') {
                    await bot.sendPhoto(chatId, res.data.data.qris_url, { 
                        caption: `💰 *QRIS TOPUP*\nNominal: ${formatRupiah(nominal)}\nTotal: *${formatRupiah(res.data.data.total_amount)}*\n\nOtomatis masuk setelah bayar.`,
                        parse_mode: 'Markdown'
                    });
                }
            } catch (e) { bot.sendMessage(chatId, '❌ Gagal membuat QRIS.'); }
        }
        else if (state === 'WAITING_CEK_AKRAB') {
            let phone = text.replace(/[^0-9]/g, '');
            if (phone.startsWith('0')) phone = '62' + phone.slice(1);
            delete userState[chatId];
            await bot.sendMessage(chatId, '🔍 Mengecek...');
            try {
                const res = await axios.get(`https://apigw.kmsp-store.com/sidompul/v4/cek_akrab`, { 
                    params: { msisdn: phone, isJSON: 'true' }, 
                    headers: { "Authorization": config.sidompulAuth, "X-API-Key": config.sidompulKey } 
                });
                let hasil = res.data.data.hasil.replace(/<br>/g, "\n").replace(/📃 RESULT:/g, "👨‍👩‍👧‍👦 *DETAIL AKRAB*");
                await bot.sendMessage(chatId, hasil, { parse_mode: 'Markdown' });
            } catch (e) { bot.sendMessage(chatId, '❌ Tidak ditemukan.'); }
        }
    } catch (err) {
        bot.sendMessage(chatId, '❌ Terjadi kesalahan.');
    }
});
// --- PROSES TAMBAH SALDO BY OWNER ---
        else if (state === 'OWNER_WAITING_ID_ADD') {
            const targetId = text.trim();
            if (!userBalance[targetId]) return bot.sendMessage(chatId, "❌ ID tidak terdaftar di database.");
            tempOrder[chatId] = { targetId }; // Simpan ID sementara
            userState[chatId] = 'OWNER_WAITING_AMOUNT_ADD';
            await bot.sendMessage(chatId, `👤 User: ${targetId}\n💰 Masukkan nominal saldo:`);
        }
        else if (state === 'OWNER_WAITING_AMOUNT_ADD') {
            const amount = parseInt(text.replace(/[^0-9]/g, ''));
            const targetId = tempOrder[chatId].targetId;
            
            userBalance[targetId].balance += amount;
            saveDB(config.userBalanceFile, userBalance);
            
            delete userState[chatId];
            delete tempOrder[chatId];
            
            await bot.sendMessage(chatId, `✅ Berhasil menambah *${formatRupiah(amount)}* ke ID \`${targetId}\``, { parse_mode: 'Markdown' });
            // Notif ke User
            bot.sendMessage(targetId, `🎁 *SALDO MASUK!*\nOwner telah menambahkan saldo sebesar *${formatRupiah(amount)}* ke akunmu.`, { parse_mode: 'Markdown' });
        }

        // --- PROSES UBAH ROLE BY OWNER ---
        else if (state === 'OWNER_WAITING_ID_ROLE') {
            const targetId = text.trim();
            if (!userBalance[targetId]) return bot.sendMessage(chatId, "❌ ID tidak terdaftar.");
            
            await bot.sendMessage(chatId, `🎭 Pilih Role baru untuk \`${targetId}\`:`, {
                reply_markup: {
                    inline_keyboard: [
                        [{ text: 'Member', callback_data: `setrole_${targetId}_member` }, { text: 'Reseller', callback_data: `setrole_${targetId}_reseller` }]
                    ]
                }
            });
            delete userState[chatId];
        }
if (data.startsWith('setrole_')) {
            const [ , targetId, role ] = data.split('_');
            userBalance[targetId].role = role;
            saveDB(config.userBalanceFile, userBalance);
            await bot.sendMessage(chatId, `✅ User \`${targetId}\` sekarang adalah *${role.toUpperCase()}*`, { parse_mode: 'Markdown' });
            bot.sendMessage(targetId, `👑 *UPDATE ROLE*\nSelamat! Akun kamu telah diubah menjadi *${role.toUpperCase()}* oleh admin.`);
        }
// --- PROSES BROADCAST OLEH OWNER ---
        else if (state === 'OWNER_WAITING_BC_TEXT') {
            const pesanBC = text;
            const allUsers = Object.keys(userBalance);
            let sukses = 0;

            delete userState[chatId];
            await bot.sendMessage(chatId, `🚀 *Memulai Broadcast...*\nTarget: ${allUsers.length} user.`);

            for (const id of allUsers) {
                try {
                    // Jeda 50ms agar tidak terkena spam limit Telegram
                    await new Promise(r => setTimeout(r, 50)); 
                    await bot.sendMessage(id, `📢 *PENGUMUMAN*\n\n${pesanBC}`, { parse_mode: 'Markdown' });
                    sukses++;
                } catch (e) { }
            }
            await bot.sendMessage(chatId, `✅ *BROADCAST SELESAI*\nTerkirim ke ${sukses} user.`);
        }     

// ==========================================
// 5. OWNER COMMANDS
// ==========================================

bot.onText(/\/setrole (\d+) (member|reseller)/, (msg, match) => {
    if (msg.from.id !== config.ownerId) return;
    const target = match[1];
    const newRole = match[2].toLowerCase();
    if (!userBalance[target]) userBalance[target] = { balance: 0, role: 'member' };
    userBalance[target].role = newRole;
    saveDB(config.userBalanceFile, userBalance);
    bot.sendMessage(msg.chat.id, `✅ User ${target} jadi ${newRole.toUpperCase()}`);
});

bot.onText(/\/add (\d+) (\d+)/, (msg, match) => {
    if (msg.from.id !== config.ownerId) return;
    const target = match[1];
    const jml = parseInt(match[2]);
    if (userBalance[target]) {
        userBalance[target].balance += jml;
        saveDB(config.userBalanceFile, userBalance);
        bot.sendMessage(msg.chat.id, `✅ Saldo ${target} +${jml}`);
    }
});

bot.onText(/\/listuser/, (msg) => {
    if (msg.from.id !== config.ownerId) return;

    let text = "👥 *DAFTAR PENGGUNA*\n\n";
    const users = Object.keys(userBalance);

    if (users.length === 0) return bot.sendMessage(msg.chat.id, "Belum ada user terdaftar.");

    users.forEach((id, index) => {
        const u = userBalance[id];
        text += `${index + 1}. ID: \`${id}\`\n   Role: *${u.role.toUpperCase()}*\n   Saldo: ${formatRupiah(u.balance)}\n\n`;
    });

    bot.sendMessage(msg.chat.id, text, { parse_mode: 'Markdown' });
});
// ==========================================
// 6. AUTO BACKUP SYSTEM
// ==========================================

// Fungsi Inti Backup
const runBackup = async (targetId) => {
    const dbFolder = './database';
    try {
        if (!fs.existsSync(dbFolder)) return;
        
        const files = fs.readdirSync(dbFolder);
        if (files.length === 0) return;

        await bot.sendMessage(targetId, "🤖 *AUTO BACKUP SYSTEM*\nMenghidupkan pencadangan otomatis hari ini...", { parse_mode: 'Markdown' });

        for (const file of files) {
            const filePath = `${dbFolder}/${file}`;
            if (fs.lstatSync(filePath).isFile()) {
                await bot.sendDocument(targetId, filePath, { 
                    caption: `📄 *File:* \`${file}\`\n📅 *Tgl:* ${new Date().toLocaleDateString('id-ID')}`,
                    parse_mode: 'Markdown'
                });
            }
        }
    } catch (e) {
        console.error("Backup Error: ", e);
    }
};

// Logika Penjadwalan (Cek setiap menit)
setInterval(() => {
    const sekarang = new Date();
    const jam = sekarang.getHours();
    const menit = sekarang.getMinutes();

    // Setel ke Jam 00:00 (Tengah Malam)
    if (jam === 0 && menit === 0) {
        console.log('Menjalankan Auto Backup Tengah Malam...');
        runBackup(config.ownerId);
    }
}, 60000); // Cek setiap 60 detik

console.log('Bot Fantunnel V2 Active! 🚀');