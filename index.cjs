const TelegramBot = require('node-telegram-bot-api');
const fs = require('fs');
const axios = require('axios');

// ==========================================
// 1. KONFIGURASI UTAMA
// ==========================================
const config = {
    token: "8595583887:AAEetqI53eeJAbf_u6pSo54Z7HM29vN_dn4", 
    ownerId: 6197482164, 
    botUsername: "FANTUNNEL_PPOB_BOT", 
    notifGroupId: "-1002076809846",
    
    // File Database
    userBalanceFile: "./database/user_balance.json", 
    historyFile: "./database/history.json",
    xlSessionsFile: "./database/xl_sessions.json",
    digitalStockFile: "./database/digital_stock.json", // File Database Stok Produk Digital
    
    // API Keys (KMSP & Payment)
    apiKeyKMSP: "29dc3989-2394-448d-a7a5-8a6c3fa59f5d", 
    apiKeyPayment: "e435777e-47ed-4485-a06c-767dbe895d1f", 
    
    // Sidompul (Cek Kuota)
    sidompulAuth: "Basic c2lkb21wdWxhcGk6YXBpZ3drbXNw",
    sidompulKey: "60ef29aa-a648-4668-90ae-20951ef90c55", 
    
    // Harga & Margin
    markupMember: 3000,    
    markupReseller: 1000,
    priceUpgradeReseller: 10000,
    targetReward: 20, 
    bonusReward: 2000,
    bonusReferralUpgrade: 2000
};

const botStartTime = Date.now();
const bot = new TelegramBot(config.token, { polling: true });

// ==========================================
// 2. DATABASE HANDLER
// ==========================================
if (!fs.existsSync('./database')) fs.mkdirSync('./database');

const loadDB = (file, defaultVal) => {
    try {
        if (!fs.existsSync(file)) {
            fs.writeFileSync(file, JSON.stringify(defaultVal, null, 2));
            return defaultVal;
        }
        return JSON.parse(fs.readFileSync(file));
    } catch (e) {
        console.error(`Error loading DB ${file}:`, e);
        return defaultVal;
    }
};

const saveDB = (file, data) => {
    try { fs.writeFileSync(file, JSON.stringify(data, null, 2)); } 
    catch (e) { console.error(`Error saving DB ${file}:`, e); }
};

// Load Database ke Memory
let userBalance = loadDB(config.userBalanceFile, {}); 
let historyTrx = loadDB(config.historyFile, []);
let xlSessions = loadDB(config.xlSessionsFile, {});
let digitalStock = loadDB(config.digitalStockFile, { "vps_panel": [], "vps_murah": [], "apk_premium": [] });

// State Management (Penyimpan sesi sementara)
const userState = {}; 
const tempOrder = {}; 
const isProcessing = {}; // Anti spam tombol

// Helper Functions
const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

const getUserData = (userId, referrerId = null) => {
    if (!userBalance[userId]) {
        userBalance[userId] = { balance: 0, role: 'member', referredBy: (referrerId && referrerId != userId) ? referrerId : null };
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
    return `${days}d ${hours}h ${minutes}m ${seconds}s`;
};

// ==========================================
// 3. TAMPILAN MENU UTAMA (SPLIT VERSION)
// ==========================================
const sendMainMenu = async (chatId, userId, name, messageId = null) => {
    const userData = getUserData(userId);
    const totalUsers = Object.keys(userBalance).length;
    let totalTrx = 0;
    historyTrx.forEach(t => { totalTrx += (t.price || 0); });

    const menuMsg = `
┏━━━━━━━━━━━━━━━━━━━┓
┃    ✨ *FANTUNNEL STORE* ✨    ┃
┗━━━━━━━━━━━━━━━━━━━┛
👋 Halo, *${name}*
───────────────────
👤 *Role* : ${userData.role.toUpperCase()}
💰 *Saldo* : ${formatRupiah(userData.balance)}
⏳ *Runtime* : ${getRuntime()}
───────────────────
📊 *Statistik Bot:*
👥 User: ${totalUsers} | 🌍 Total TRX: ${formatRupiah(totalTrx)}
───────────────────
Silahkan pilih layanan kami:
    `;

    const opts = {
        reply_markup: {
            inline_keyboard: [
                [{ text: '📱 LAYANAN PPOB (XL/DATA)', callback_data: 'sub_menu_ppob' }],
                [{ text: '🚀 PRODUK DIGITAL (VPS/APK)', callback_data: 'sub_menu_digital' }],
                [{ text: '💰 Isi Saldo', callback_data: 'menu_topup' }, { text: '👤 Profil', callback_data: 'menu_profile' }],
                [{ text: '👑 Upgrade Reseller', callback_data: 'menu_reseller' }, { text: '🎁 Referral', callback_data: 'menu_referral' }],
                [{ text: '📖 Panduan Bot', callback_data: 'menu_panduan' }, { text: '🏆 Top Transaksi', callback_data: 'owner_leaderboard' }],
                [{ text: '👤 Owner Panel', callback_data: 'menu_owner' }]
            ]
        }
    };

    try {
        if (messageId) {
            return await bot.editMessageCaption(menuMsg, { chat_id: chatId, message_id: messageId, reply_markup: opts.reply_markup, parse_mode: 'Markdown' });
        } else {
            const logoPath = './logo.jpg';
            if (fs.existsSync(logoPath)) {
                return await bot.sendPhoto(chatId, fs.createReadStream(logoPath), { caption: menuMsg, parse_mode: 'Markdown', reply_markup: opts.reply_markup });
            } else {
                return await bot.sendMessage(chatId, menuMsg, { parse_mode: 'Markdown', reply_markup: opts.reply_markup });
            }
        }
    } catch (e) { console.error("Error Menu Utama:", e.message); }
};

// ==========================================
// 4. MESSAGE HANDLER (Perintah Dasar & Input Text)
// ==========================================
bot.on('message', async (msg) => {
    const chatId = msg.chat.id;
    const userId = msg.from.id;
    const text = msg.text || '';

    // CMD Start & Menu
    if (text.startsWith('/start') || text.startsWith('/menu')) {
        const referrerId = text.split(' ')[1];
        getUserData(userId, referrerId); 
        return sendMainMenu(chatId, userId, msg.from.first_name);
    }

    // Input Data Tambah Stok Digital (Khusus Owner)
    if (userState[chatId] === 'WAITING_STOCK_TYPE') {
        tempOrder[chatId] = { stockKey: text.trim().toLowerCase() };
        userState[chatId] = 'WAITING_STOCK_DATA';
        return bot.sendMessage(chatId, `📦 Kategori: *${tempOrder[chatId].stockKey}*\n\n👉 Masukkan data akun (bisa banyak, pisahkan dengan **Enter** / baris baru):`, {parse_mode: 'Markdown'});
    }
    
    if (userState[chatId] === 'WAITING_STOCK_DATA') {
        const newItems = text.split('\n').filter(i => i.trim() !== "");
        const key = tempOrder[chatId].stockKey;
        
        if (!digitalStock[key]) digitalStock[key] = [];
        digitalStock[key] = [...digitalStock[key], ...newItems]; // Tambahkan ke stok yang ada
        
        saveDB(config.digitalStockFile, digitalStock);
        delete userState[chatId];
        delete tempOrder[chatId];
        
        return bot.sendMessage(chatId, `✅ *SUKSES!*\nBerhasil menambah ${newItems.length} stok ke kategori *${key}*.`, {parse_mode: 'Markdown'});
    }

    // ===============================================
    // NOTE: Tambahkan logika state PPOB milikmu di sini 
    // seperti input Nomor HP, Topup Saldo, Login XL, dll
    // Contoh aslimu:
    // if (userState[chatId] === 'WAITING_BUY_PHONE') { ... }
    // if (userState[chatId] === 'WAITING_TOPUP_AMOUNT') { ... }
    // ===============================================
});

// ==========================================
// 5. CALLBACK QUERY HANDLER (Logic Utama Full)
// ==========================================
bot.on('callback_query', async (callback) => {
    const chatId = callback.message.chat.id;
    const messageId = callback.message.message_id;
    const data = callback.data;
    const userId = callback.from.id;
    const userData = getUserData(userId);

    try {
        // --- NAVIGASI KEMBALI ---
        if (data === 'back_to_menu') {
            await sendMainMenu(chatId, userId, callback.from.first_name, messageId);
        }

        // --- SUB MENU PPOB ---
        else if (data === 'sub_menu_ppob') {
            await bot.editMessageCaption('📱 *LAYANAN PPOB & XL TEMBAK*\nSilahkan pilih fitur PPOB:', {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '🛒 Beli Paket', callback_data: 'menu_list' }, { text: '🔍 Cek Kuota', callback_data: 'menu_cekkouta' }],
                        [{ text: '🔐 Login XL', callback_data: 'menu_xl_login' }, { text: '📊 Info XL', callback_data: 'menu_xl_info' }],
                        [{ text: '👨‍👩‍👧‍👦 Cek Akrab', callback_data: 'menu_cek_akrab' }, { text: '📜 Riwayat TRX', callback_data: 'menu_history' }],
                        [{ text: '📦 Ganti Akun / Logout XL', callback_data: 'logout_xl' }],
                        [{ text: '🔙 KEMBALI', callback_data: 'back_to_menu' }]
                    ]
                }
            });
        }

        // --- SUB MENU PRODUK DIGITAL ---
        else if (data === 'sub_menu_digital') {
            await bot.editMessageCaption('🚀 *PRODUK DIGITAL TERSEDIA*\nPembelian otomatis. Data akun langsung dikirim setelah bayar:', {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: `🖥️ Panel VPS | ${formatRupiah(15000)}`, callback_data: 'buy_vps_panel' }],
                        [{ text: `☁️ VPS Murah | ${formatRupiah(25000)}`, callback_data: 'buy_vps_murah' }],
                        [{ text: `📱 APK Premium | ${formatRupiah(10000)}`, callback_data: 'buy_apk_premium' }],
                        [{ text: '🔙 KEMBALI', callback_data: 'back_to_menu' }]
                    ]
                }
            });
        }

        // =========================================================
        // LOGIKA AUTO-ORDER PRODUK DIGITAL (BARU)
        // =========================================================
        const digitalProducts = {
            'buy_vps_panel': { name: 'Panel VPS', price: 15000, key: 'vps_panel' },
            'buy_vps_murah': { name: 'VPS Murah', price: 25000, key: 'vps_murah' },
            'buy_apk_premium': { name: 'APK Premium', price: 10000, key: 'apk_premium' }
        };

        if (digitalProducts[data]) {
            const product = digitalProducts[data];
            
            if (userData.balance < product.price) return bot.answerCallbackQuery(callback.id, { text: "❌ Saldo Anda tidak cukup!", show_alert: true });

            let currentStock = digitalStock[product.key] || [];
            if (currentStock.length === 0) return bot.answerCallbackQuery(callback.id, { text: "⚠️ Stok sedang kosong, hubungi Admin.", show_alert: true });

            // Proses Ambil Stok (First In First Out)
            const accountData = currentStock.shift(); 
            digitalStock[product.key] = currentStock; 
            saveDB(config.digitalStockFile, digitalStock);

            // Potong Saldo & Simpan History
            userBalance[userId].balance -= product.price;
            userBalance[userId].total_trx = (userBalance[userId].total_trx || 0) + 1;
            
            historyTrx.push({ userId, date: new Date().toISOString(), product: product.name, price: product.price, status: 'SUCCESS', detail: accountData });
            saveDB(config.userBalanceFile, userBalance);
            saveDB(config.historyFile, historyTrx);

            // Kirim ke User
            const successMsg = `
✅ *PEMBELIAN BERHASIL!*
━━━━━━━━━━━━━━━━━━
📦 *Produk:* ${product.name}
💰 *Harga:* ${formatRupiah(product.price)}
📅 *Waktu:* ${new Date().toLocaleString('id-ID')}
━━━━━━━━━━━━━━━━━━
🚀 *DATA AKUN / AKSES:*
\`${accountData}\`
━━━━━━━━━━━━━━━━━━
_Catatan: Simpan data ini baik-baik._
            `;
            await bot.sendMessage(chatId, successMsg, { parse_mode: 'Markdown' });

            // Notif ke Grup
            if (config.notifGroupId) {
                const textGrup = `
🔔 *DIGITAL PRODUK TERJUAL*
━━━━━━━━━━━━━━━━━━
👤 *User:* ${callback.from.first_name}
📦 *Produk:* ${product.name}
💰 *Harga:* ${formatRupiah(product.price)}
📉 *Sisa Stok:* ${currentStock.length}
━━━━━━━━━━━━━━━━━━
Status: *AUTO-SEND SUCCESS*`;
                bot.sendMessage(config.notifGroupId, textGrup, { parse_mode: 'Markdown' }).catch(()=>{});
            }
        }

        // =========================================================
        // OWNER PANEL (FULL PPOB + TAMBAH STOK DIGITAL)
        // =========================================================
        else if (data === 'menu_owner') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "❌ Akses Ditolak" });
            await bot.editMessageCaption("👑 *OWNER DASHBOARD*\n\nKelola sistem, saldo supplier, dan stok produk digital di sini:", {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '📦 Tambah Stok Digital', callback_data: 'owner_add_digital_stock' }], // Tombol Digital Stok
                        [{ text: '💰 Saldo Supplier KMSP', callback_data: 'owner_cek_saldo_kmsp' }],
                        [{ text: '➕ Tambah Saldo User', callback_data: 'owner_add_saldo' }, { text: '🎭 Set Role User', callback_data: 'owner_set_role' }],
                        [{ text: '📢 Broadcast', callback_data: 'owner_broadcast' }],
                        [{ text: '🗑️ Reset Riwayat TRX', callback_data: 'owner_reset_history' }],
                        [{ text: '🏠 Menu Utama', callback_data: 'back_to_menu' }]
                    ]
                }
            });
        }
        else if (data === 'owner_add_digital_stock') {
            if (userId !== config.ownerId) return;
            userState[chatId] = 'WAITING_STOCK_TYPE';
            bot.sendMessage(chatId, "Pilih kategori stok yang mau ditambah (ketik manual):\n- `vps_panel`\n- `vps_murah`\n- `apk_premium`", {parse_mode: 'Markdown'});
        }
        else if (data === 'owner_add_saldo') {
            userState[chatId] = 'OWNER_WAITING_ID_ADD';
            bot.sendMessage(chatId, "Masukkan ID User:");
        }
        else if (data === 'owner_set_role') {
            userState[chatId] = 'OWNER_WAITING_ID_ROLE';
            bot.sendMessage(chatId, "Masukkan ID User untuk ganti role:");
        }
        else if (data.startsWith('setrole_')) {
            const [ , targetId, role] = data.split('_');
            if (userBalance[targetId]) {
                userBalance[targetId].role = role;
                saveDB(config.userBalanceFile, userBalance);
                await bot.sendMessage(chatId, `✅ Berhasil! User ${targetId} sekarang adalah ${role.toUpperCase()}`);
            }
        }
        else if (data === 'owner_reset_history') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "❌ Akses Ditolak" });
            await bot.editMessageCaption("⚠️ *PERINGATAN BAHAYA!*\n\nApakah Anda yakin ingin menghapus **SEMUA** riwayat transaksi dari sistem?\n\n_Data yang sudah dihapus tidak dapat dikembalikan lagi!_", {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '✅ YA, KOSONGKAN RIWAYAT', callback_data: 'confirm_reset_history' }],
                        [{ text: '❌ BATAL', callback_data: 'menu_owner' }]
                    ]
                }
            });
        }
        else if (data === 'confirm_reset_history') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "❌ Akses Ditolak" });
            historyTrx.length = 0; 
            saveDB(config.historyFile, historyTrx);
            await bot.editMessageCaption("🗑️ *RIWAYAT BERHASIL DIHAPUS*\n\nDatabase riwayat sekarang kosong seperti baru.", {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '🔙 Kembali ke Panel Owner', callback_data: 'menu_owner' }]] }
            });
        }
        else if (data === 'owner_cek_saldo_kmsp') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "Akses Ditolak" });
            await bot.answerCallbackQuery(callback.id, { text: "🔍 Menghubungi Server KMSP..." });
            try {
                const res = await axios.get(`https://golang-openapi-panelaccountbalance-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP }, timeout: 20000 
                });
                const dataKMSP = res.data.data || res.data;
                const saldoPusat = dataKMSP.balance;

                if (saldoPusat !== undefined) {
                    let peringatan = saldoPusat < 50000 ? "\n\n⚠️ *PERINGATAN:* Saldo menipis, segera topup di KMSP!" : "";
                    await bot.sendMessage(chatId, `💰 *INFO SALDO PUSAT (KMSP)*\n\nSaldo Modal Anda saat ini: *${formatRupiah(saldoPusat)}*${peringatan}`, { parse_mode: 'Markdown' });
                } else {
                    await bot.sendMessage(chatId, "⚠️ Gagal membaca format saldo dari API.");
                }
            } catch (e) { bot.sendMessage(chatId, `❌ Gagal mengambil info saldo pusat: ${e.message}`); }
        }

        // =========================================================
        // FULL LOGIKA PPOB (KMSP, MENU BELI, DLL)
        // =========================================================
        else if (data === 'menu_list') {
            await bot.editMessageCaption('📂 *PILIH KATEGORI PAKET PPOB*:', {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '💎 BEST SELLER', callback_data: 'cat_bestseller' }, { text: '⚡ XTRA COMBO', callback_data: 'cat_combo' }],
                        [{ text: '👨‍👩‍👧‍👦 XL AKRAB', callback_data: 'cat_akrab' }, { text: '🔥 HOTROD', callback_data: 'cat_hotrod' }],
                        [{ text: '🌐 SEMUA PAKET', callback_data: 'cat_all' }], 
                        [{ text: '📊 CEK STOK AKRAB', callback_data: 'menu_stok_akrab' }],
                        [{ text: '🔙 KEMBALI', callback_data: 'sub_menu_ppob' }]
                    ]
                }
            });
        }
        else if (data.startsWith('cat_')) {
            const [ , kategori, pageStr] = data.split('_');
            const page = parseInt(pageStr) || 0;
            const itemsPerPage = 5;

            try {
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                let filtered = res.data.data;

                if (kategori === 'bestseller') filtered = filtered.filter(p => /edukasi|conference|iflix|xtra kuota/i.test(p.package_name));
                else if (kategori === 'akrab') filtered = filtered.filter(p => p.package_name.toLowerCase().includes('akrab'));
                else if (kategori === 'combo') filtered = filtered.filter(p => p.package_name.toLowerCase().includes('combo'));
                else if (kategori === 'hotrod') filtered = filtered.filter(p => p.package_name.toLowerCase().includes('hotrod'));

                const totalPages = Math.ceil(filtered.length / itemsPerPage);
                const paginatedItems = filtered.slice(page * itemsPerPage, (page + 1) * itemsPerPage);
                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                const roleIcon = userData.role === 'reseller' ? "💎 RESELLER" : "👤 MEMBER";

                let pText = `📦 *KATEGORI: ${kategori.toUpperCase()}*\n🎭 *TIPE AKUN:* ${roleIcon}\n📖 *HALAMAN:* ${page + 1}/${totalPages}\n━━━━━━━━━━━━━━━━━━\n\n`;
                const inlineKeyboard = [];

                paginatedItems.forEach(p => {
                    const hargaJual = p.package_harga_int + markup;
                    pText += `🔹 *${p.package_name}*\n💰 *${formatRupiah(hargaJual)}*\n──────────────────\n`;
                    inlineKeyboard.push([{ text: `🛒 BELI | ${formatRupiah(hargaJual)}`, callback_data: `buy_direct_${p.package_code}` }]);
                });

                const nav = [];
                if (page > 0) nav.push({ text: '⬅️ Prev', callback_data: `cat_${kategori}_${page - 1}` });
                if ((page + 1) * itemsPerPage < filtered.length) nav.push({ text: 'Next ➡️', callback_data: `cat_${kategori}_${page + 1}` });
                
                if (nav.length > 0) inlineKeyboard.push(nav);
                inlineKeyboard.push([{ text: '🔙 KEMBALI KATEGORI', callback_data: 'menu_list' }]);

                await bot.editMessageCaption(pText, { chat_id: chatId, message_id: messageId, parse_mode: 'Markdown', reply_markup: { inline_keyboard: inlineKeyboard } });
            } catch (err) {
                bot.answerCallbackQuery(callback.id, { text: "❌ Gagal memuat data dari pusat." });
            }
        }
        else if (data.startsWith('buy_direct_')) {
            const code = data.replace('buy_direct_', '');
            await bot.answerCallbackQuery(callback.id, { text: "⏳ Mengecek ketersediaan..." });

            try {
                const resSaldo = await axios.get(`https://golang-openapi-panelaccountbalance-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                const saldoModal = resSaldo.data.data.balance || resSaldo.data.balance;

                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                const p = res.data.data.find(x => x.package_code === code);
                
                if (!p) return bot.sendMessage(chatId, "❌ Paket tidak ditemukan.");

                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                const hargaJual = p.package_harga_int + markup;

                if (saldoModal < p.package_harga_int) {
                    return bot.sendMessage(chatId, `⚠️ *STOK SEDANG RE-FILL*\n\nMohon maaf Bos, saldo modal admin di pusat sedang menipis (${formatRupiah(saldoModal)}).`);
                }
                
                tempOrder[chatId] = { package_code: code, price_sell: hargaJual, name: p.package_name };

                if (userBalance[userId].saved_phone) {
                    tempOrder[chatId].phone = userBalance[userId].saved_phone;
                    await bot.sendMessage(chatId, `🛒 *ORDER:* ${p.package_name}\n💰 *HARGA:* ${formatRupiah(hargaJual)}\n📱 *NOMOR:* \`${tempOrder[chatId].phone}\`\n\nIngin menggunakan nomor ini lagi?`, {
                        parse_mode: 'Markdown',
                        reply_markup: {
                            inline_keyboard: [[{ text: '✅ YA, LANJUTKAN', callback_data: 'confirm_buy' }], [{ text: '🔄 GANTI NOMOR', callback_data: 'logout_xl_direct' }]]
                        }
                    });
                } else {
                    userState[chatId] = 'WAITING_BUY_PHONE';
                    await bot.sendMessage(chatId, `🛒 *ORDER:* ${p.package_name}\n💰 *HARGA:* ${formatRupiah(hargaJual)}\n\n👉 *Masukkan NOMOR HP (XL):*`, { parse_mode: 'Markdown' });
                }
            } catch (e) { bot.sendMessage(chatId, "⚠️ Terjadi gangguan koneksi ke server pusat."); }
        }
        else if (data === 'logout_xl_direct') {
            userBalance[userId].saved_phone = null;
            saveDB(config.userBalanceFile, userBalance);
            userState[chatId] = 'WAITING_BUY_PHONE';
            await bot.editMessageText("🔄 *NOMOR DIRESET*\n\n👉 Sekarang masukkan **NOMOR HP (XL)** baru:", { chat_id: chatId, message_id: messageId, parse_mode: 'Markdown' });
        }
        else if (data === 'logout_xl') {
             userBalance[userId].saved_phone = null;
             saveDB(config.userBalanceFile, userBalance);
             await bot.answerCallbackQuery(callback.id, { text: "✅ Akun/Nomor berhasil dihapus dari memori." });
        }
        
        // --- PROSES BELI KMSP ---
        else if (data === 'confirm_buy') {
            const order = tempOrder[chatId];
            if (!order) return bot.sendMessage(chatId, "❌ Sesi habis.");
            if (userData.balance < order.price_sell) return bot.sendMessage(chatId, "❌ Saldo kurang.");
            if (isProcessing[chatId]) return;

            isProcessing[chatId] = true;
            try {
                await bot.editMessageText("⏳ *SEDANG DIPROSES...*", { chat_id: chatId, message_id: messageId, parse_mode: 'Markdown' });
                const res = await axios.get(`https://golang-openapi-packagepurchase-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, phone: order.phone, package_code: order.package_code }
                });

                if (res.data && res.data.status) {
                    userBalance[userId].balance -= order.price_sell;
                    userBalance[userId].saved_phone = order.phone; 

                    userBalance[userId].total_trx = (userBalance[userId].total_trx || 0) + 1;
                    const currentTrx = userBalance[userId].total_trx;

                    // Reward
                    if (currentTrx % 20 === 0) {
                        userBalance[userId].balance += config.bonusReward;
                        bot.sendMessage(userId, `🎉 *BONUS CAIR!* Saldo +${formatRupiah(config.bonusReward)} karena mencapai ${currentTrx} transaksi!`);
                    }

                    // Auto-Upgrade Reseller
                    if (currentTrx >= 50 && userBalance[userId].role !== 'reseller') {
                        userBalance[userId].role = 'reseller';
                        bot.sendMessage(userId, `🎊 *SELAMAT!* Anda resmi menjadi **RESELLER**!\nSekarang Anda mendapatkan harga lebih murah.`);
                        bot.sendMessage(config.ownerId, `🚀 *UPGRADE ROLE:* User ${userId} otomatis jadi Reseller.`);
                    }

                    historyTrx.push({ userId, date: new Date().toISOString(), product: order.name, price: order.price_sell, status: 'SUCCESS', phone: order.phone });
                    saveDB(config.userBalanceFile, userBalance);
                    saveDB(config.historyFile, historyTrx);

                    await bot.sendMessage(chatId, `✅ *SUKSES!*\n📦 ${order.name}\n📱 ${order.phone}\n💰 Sisa Saldo: ${formatRupiah(userBalance[userId].balance)}\n\n_Nomor HP ini telah disimpan untuk transaksi berikutnya._`, { parse_mode: 'Markdown' });

                    if (config.notifGroupId) {
                        const textGrup = `🔔 *TRANSAKSI BARU PPOB*\n━━━━━━━━━━━━━━━━━━\n👤 *Pembeli:* ${callback.from.first_name}\n📦 *Produk:* ${order.name}\n📱 *Nomor:* \`${order.phone}\`\n💰 *Harga:* ${formatRupiah(order.price_sell)}\n🎭 *Role:* ${userData.role.toUpperCase()}\n━━━━━━━━━━━━━━━━━━\nStatus: *BERHASIL (LUNAS)*`;
                        await bot.sendMessage(config.notifGroupId, textGrup, { parse_mode: 'Markdown' }).catch(()=>{});
                    }

                    delete tempOrder[chatId];
                } else {
                    await bot.sendMessage(chatId, `❌ Gagal: ${res.data.message}`);
                }
            } catch (e) { bot.sendMessage(chatId, "⚠️ Gangguan Server"); } finally { delete isProcessing[chatId]; }
        }

        // --- TOPUP, RESELLER, REFERRAL ---
        else if (data === 'menu_topup') {
            userState[chatId] = 'WAITING_TOPUP_AMOUNT';
            await bot.sendMessage(chatId, '💰 *ISI SALDO OTOMATIS*\n\nMasukkan nominal Topup (Min. 1.000):', { parse_mode: 'Markdown' });
        }
        else if (data === 'check_payment') {
            const order = tempOrder[chatId];
            if (!order || order.type !== 'topup') return bot.sendMessage(chatId, '❌ Sesi expired.');
            const res = await axios.get(`https://my-payment.autsc.my.id/api/status/payment`, { params: { transaction_id: order.trx_id, apikey: config.apiKeyPayment } });
            if (res.data.paid) {
                userBalance[userId].balance += order.amount_added;
                saveDB(config.userBalanceFile, userBalance);
                delete tempOrder[chatId];
                await bot.sendMessage(chatId, `✅ *TOPUP BERHASIL*\nSaldo masuk: ${formatRupiah(order.amount_added)}`, { parse_mode: 'Markdown' });
            } else {
                bot.answerCallbackQuery(callback.id, { text: "⏳ Belum ada pembayaran." });
            }
        }
        else if (data === 'menu_reseller') {
            if (userData.role === 'reseller') return bot.answerCallbackQuery(callback.id, { text: "Sudah Reseller!" });
            await bot.editMessageCaption(`👑 *UPGRADE RESELLER*\n\nBiaya: *${formatRupiah(config.priceUpgradeReseller)}*\nBenefit: Harga lebih murah & Prioritas.\n\nKlik setuju untuk potong saldo:`, {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '✅ SETUJU', callback_data: 'confirm_upgrade' }], [{ text: '❌ BATAL', callback_data: 'back_to_menu' }]] }
            });
        }
        else if (data === 'confirm_upgrade') {
            if (userData.balance < config.priceUpgradeReseller) return bot.sendMessage(chatId, "❌ Saldo tidak cukup.");
            userBalance[userId].balance -= config.priceUpgradeReseller;
            userBalance[userId].role = 'reseller';
            
            if (userData.referredBy && userBalance[userData.referredBy]) {
                userBalance[userData.referredBy].balance += config.bonusReferralUpgrade;
                bot.sendMessage(userData.referredBy, `💰 *BONUS REFERRAL!*\nTeman Anda upgrade reseller. Saldo +${formatRupiah(config.bonusReferralUpgrade)}`, { parse_mode: 'Markdown' });
            }
            saveDB(config.userBalanceFile, userBalance);
            await bot.sendMessage(chatId, "🎉 *SUKSES!* Sekarang Anda adalah RESELLER.", { parse_mode: 'Markdown' });
        }
        else if (data === 'menu_referral') {
            const link = `https://t.me/${config.botUsername}?start=${userId}`;
            await bot.sendMessage(chatId, `🎁 *REFERRAL*\nDapatkan *${formatRupiah(config.bonusReferralUpgrade)}* setiap teman upgrade Reseller!\n\nLink kamu:\n\`${link}\``, { parse_mode: 'Markdown' });
        }

        // --- SIDOMPUL & XL TOOLS ---
        else if (data === 'menu_cekkouta') {
            userState[chatId] = 'WAITING_CHECK_QUOTA';
            await bot.sendMessage(chatId, '🔍 *CEK KUOTA*\nMasukkan nomor XL (08xx):', { parse_mode: 'Markdown' });
        }
        else if (data === 'menu_cek_akrab') {
            userState[chatId] = 'WAITING_CEK_AKRAB';
            await bot.sendMessage(chatId, '👨‍👩‍👧‍👦 *CEK AKRAB*\nMasukkan nomor XL pengelola:', { parse_mode: 'Markdown' });
        }
        else if (data === 'menu_stok_akrab') {
            await bot.answerCallbackQuery(callback.id, { text: "🔍 Menghubungi Server Sidompul..." });
            try {
                await bot.editMessageCaption("⏳ *MENGHUBUNGI SERVER SIDOMPUL...*\nSedang memproses autentikasi dan cek stok.", {
                    chat_id: chatId, message_id: messageId, parse_mode: 'Markdown'
                }).catch(() => {});

                const res = await axios.get(`https://golang-openapi-checkpackagestockakrabglobal-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP },
                    headers: { "Authorization": config.sidompulAuth, "X-API-Key": config.sidompulKey, "X-App-Version": "4.0.0" },
                    timeout: 40000 
                });

                if (res.data && res.data.data) {
                    let txt = `📊 *STOK LIVE SIDOMPUL*\n━━━━━━━━━━━━━━━━━━\n\n`;
                    const kb = [];

                    res.data.data.forEach(p => {
                        txt += `✅ *${p.package_name}*\n📝 Status: Available\n\n`;
                        kb.push([{ text: `🛒 BELI: ${p.package_name.split(' ')[0]}...`, callback_data: `buy_direct_${p.package_code}` }]);
                    });

                    kb.push([{ text: '🔙 KEMBALI', callback_data: 'menu_list' }]);
                    await bot.editMessageCaption(txt, { chat_id: chatId, message_id: messageId, parse_mode: 'Markdown', reply_markup: { inline_keyboard: kb } });
                } else {
                    await bot.sendMessage(chatId, "⚠️ *STOK TIDAK DITEMUKAN*\nRespon sukses tapi data kosong. Mungkin stok regional sedang habis.", { parse_mode: 'Markdown' });
                }
            } catch (e) {
                let detailError = "Koneksi Terputus.";
                if (e.response && e.response.status === 401) detailError = "Auth Sidompul Expired (Minta OTP lagi).";
                if (e.response && e.response.status === 403) detailError = "X-API-Key Salah.";
                await bot.sendMessage(chatId, `⚠️ *AUTENTIKASI GAGAL*\n\nDetail: ${detailError}\n_Pastikan login Sidompul masih aktif._`, { parse_mode: 'Markdown' });
            }
        }
        else if (data === 'menu_xl_login') {
            userState[chatId] = 'WAITING_XL_PHONE';
            await bot.sendMessage(chatId, '🔐 *LOGIN XL*\nMasukkan nomor XL untuk OTP:', { parse_mode: 'Markdown' });
        }
        else if (data === 'menu_xl_info') {
            if (!xlSessions[userId]) return bot.sendMessage(chatId, '❌ Login XL dulu.');
            await bot.sendMessage(chatId, '⏳ Loading info...');
            const res = await axios.get(`https://golang-openapi-quotadetails-xltembakservice.kmsp-store.com/v1`, {
                params: { api_key: config.apiKeyKMSP, access_token: xlSessions[userId].access_token }
            });
            if (res.data.status) {
                let t = `📊 *KUOTA ANDA*\n\n`;
                res.data.data.quotas.forEach(q => { t += `✅ *${q.name}*\nExp: ${q.expired_at}\n\n`; });
                await bot.sendMessage(chatId, t, { parse_mode: 'Markdown' });
            }
        }
        else if (data === 'menu_history') {
            try {
                const myHistory = historyTrx.filter(h => String(h.userId) === String(userId)).slice(-5).reverse();
                if (myHistory.length === 0) return bot.sendMessage(chatId, "📜 *BELUM ADA RIWAYAT*\n\nAnda belum pernah melakukan transaksi.", { parse_mode: 'Markdown' });

                let hText = "📜 *5 RIWAYAT TERAKHIR*\n━━━━━━━━━━━━━━━━━━\n\n";
                myHistory.forEach((h, i) => {
                    const statusEmoji = h.status === 'SUCCESS' ? '✅' : '❌';
                    const tanggal = h.date ? h.date.split('T')[0] : '-';
                    hText += `${i + 1}. ${statusEmoji} *${h.product}*\n`;
                    if(h.phone) hText += `   📱 No: \`${h.phone || '-'}\`\n`;
                    hText += `   💰 ${formatRupiah(h.price)} | 📅 ${tanggal}\n──────────────────\n`;
                });

                await bot.sendMessage(chatId, hText, { parse_mode: 'Markdown' });
            } catch (err) { bot.sendMessage(chatId, "⚠️ Gagal memuat riwayat."); }
        }
        else if (data === 'owner_leaderboard') {
            await bot.answerCallbackQuery(callback.id);
            // Urutkan user berdasarkan total transaksi terbanyak
            let topUsers = Object.keys(userBalance)
                .map(id => ({
                    name: userBalance[id].name || "User Baru",
                    total: userBalance[id].total_trx || 0
                }))
                .sort((a, b) => b.total - a.total)
                .slice(0, 5); // Ambil 5 besar

            let txt = `🏆 *TOP TRANSAKSI (BULAN INI)*\n━━━━━━━━━━━━━━━━━━\n\n`;
            topUsers.forEach((u, i) => {
                const medali = i === 0 ? '🥇' : i === 1 ? '🥈' : i === 2 ? '🥉' : '👤';
                txt += `${medali} *${u.name}* — ${u.total} Transaksi\n`;
            });
            txt += `\n_Tingkatkan transaksi & raih bonus saldo!_`;

            await bot.editMessageCaption(txt, { 
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '🏠 KEMBALI', callback_data: 'back_to_menu' }]] }
            });
        }

        // --- 📖 FITUR PANDUAN BOT ---
        else if (data === 'menu_panduan') {
            await bot.answerCallbackQuery(callback.id);
            const txtPanduan = `📖 *PANDUAN PENGGUNAAN BOT*\n━━━━━━━━━━━━━━━━━━\n\n` +
                `1️⃣ *ISI SALDO:* Klik menu Isi Saldo, bayar via QRIS otomatis.\n` +
                `2️⃣ *BELI PAKET:* Pilih menu Beli Paket. Nomor akan tersimpan otomatis setelah transaksi pertama.\n` +
                `3️⃣ *GANTI NOMOR:* Ingin ganti nomor? Masuk ke menu *PROFIL* > *Ganti Akun*.\n` +
                `4️⃣ *REWARD:* Tiap kelipatan *20 Transaksi*, bonus saldo *Rp 2.000* otomatis masuk!\n\n` +
                `5️⃣ *AUTO-RESELLER:* Capai *50 Transaksi* untuk harga lebih murah (Role Reseller).\n\n` +
                `6️⃣ *MAINTENANCE:* 🕒 **23:40 - 00:10 WIB** (Hindari transaksi di jam ini).\n\n` +
                `⚠️ *Penting:* Pastikan nomor XL dalam masa aktif.`;
                `• Transaksi yang sudah diproses tidak dapat dibatalkan.`;
                `• CS Aktif: 08:00 - 22:00 WIB.`;
                
                `@AJW29 AdminCS — *Solusi Kuota Murah & Cepat!*`;
            
            await bot.editMessageCaption(txtPanduan, { 
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '🏠 MENU UTAMA', callback_data: 'back_to_menu' }]] }
            });
        }
// --- MENU PROFIL (DENGAN TRACKER REWARD) ---
        else if (data === 'menu_profile') {
            const u = userBalance[userId] || { balance: 0, total_trx: 0, role: 'member' };
            const totalTrx = u.total_trx || 0;
            
            // Hitung sisa transaksi menuju reward (Target: 20)
            const targetReward = 20;
            const sisaKeReward = targetReward - (totalTrx % targetReward);
            const progress = totalTrx % targetReward;

            let pText = `👤 *PROFIL PENGGUNA*\n━━━━━━━━━━━━━━━━━━\n\n`;
            pText += `🆔 ID: \`${userId}\`\n`;
            pText += `🎭 Role: *${u.role.toUpperCase()}*\n`;
            pText += `💰 Saldo: *${formatRupiah(u.balance)}*\n`;
            pText += `📊 Total Transaksi: *${totalTrx}*\n\n`;
            
            pText += `🎁 *PROGRESS REWARD*\n`;
            pText += `[${'🟢'.repeat(Math.floor(progress/4))}${'⚪'.repeat(5 - Math.floor(progress/4))}] ${progress}/${targetReward}\n`;
            pText += `👉 _Lakukan *${sisaKeReward}* transaksi lagi untuk bonus saldo Rp 2.000!_`;

            await bot.editMessageCaption(pText, {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '🔄 Refresh', callback_data: 'menu_profile' }],
                        [{ text: '🏠 Kembali', callback_data: 'back_to_menu' }]
                    ]
                }
            });
        }

    } catch (error) {
        console.error("Terjadi kesalahan pada callback:", error.message);
    }
});

// Pesan Terminal
console.log("🚀 Bot FANTUNNEL Berjalan...");
