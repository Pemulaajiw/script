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
    
    // API Keys (KMSP & Payment)
    apiKeyKMSP: "29dc3989-2394-448d-a7a5-8a6c3fa59f5d", 
    apiKeyPayment: "e435777e-47ed-4485-a06c-767dbe895d1f", 
    
    // Sidompul (Cek Kuota)
    sidompulAuth: "Basic c2lkb21wdWxhcGk6YXBpZ3drbXNw",
    sidompulKey: "60ef29aa-a648-4668-90ae-20951ef90c55", 
    
    // Harga & Margin
    markupMember: 1380,    
    markupReseller: 800,
    priceUpgradeReseller: 10000,
    targetReward: 20, 
    bonusReward: 2000,
    bonusReferralUpgrade: 2000
};

const botStartTime = Date.now();
const bot = new TelegramBot(config.token, { polling: true });

// ==========================================
// 2. DATABASE HANDLER (Fix Logic)
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

// ==========================================
// FIX: DATABASE HANDLER & ATOMIC WRITE
// ==========================================
const saveDB = (file, data) => {
    try {
        // Tulis ke file temporary (.tmp) dulu. 
        // Jika bot mati di tengah jalan, file utama tetap aman.
        const tempFile = `${file}.tmp`;
        fs.writeFileSync(tempFile, JSON.stringify(data, null, 2));
        fs.renameSync(tempFile, file); // Replace file utama secara instan
    } catch (e) {
        console.error(`Error saving DB ${file}:`, e);
    }
};

function getUserData(userId, referrerId = null) {
    const id = String(userId); // KUNCI UTAMA: Jadikan string agar tidak ada duplikasi profile
    if (!userBalance[id]) {
        userBalance[id] = {
            balance: 0,
            role: 'member', // Default awal
            total_trx: 0,
            referred_by: referrerId,
            name: "",
            saved_phone: null
        };
        saveDB(config.userBalanceFile, userBalance);
    }
    return userBalance[id];
}

// Load Database ke Memory
let userBalance = loadDB(config.userBalanceFile, {}); 
let historyTrx = loadDB(config.historyFile, []);
let xlSessions = loadDB(config.xlSessionsFile, {});

// State Management (Penyimpan sesi sementara)
const userState = {}; 
const tempOrder = {}; 
const isProcessing = {}; // Anti spam tombol

// Helper Functions
const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

const getRuntime = () => {
    const uptime = Date.now() - botStartTime;
    const seconds = Math.floor((uptime / 1000) % 60);
    const minutes = Math.floor((uptime / (1000 * 60)) % 60);
    const hours = Math.floor((uptime / (1000 * 60 * 60)) % 24);
    const days = Math.floor(uptime / (1000 * 60 * 60 * 24));
    return `${days}d ${hours}h ${minutes}m ${seconds}s`;
};

// ==========================================
// 3. TAMPILAN MENU UTAMA
// ==========================================
const sendMainMenu = async (chatId, userId, name, messageId = null) => {
    const userData = getUserData(userId);
    const totalUsers = Object.keys(userBalance).length;
    let totalTrx = 0;
    historyTrx.forEach(t => { totalTrx += (t.price || 0); });

    const menuMsg = `
┏━━━━━━━━━━━━━━━━━━━┓
┃  ✨ *FANTUNNEL STORE* ✨    
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
☀️ [ADMIN](https://t.me/AJW29) ☀️ [GRUP](https://t.me/klmpkfsvpn) ☀️ [TESTI](https://t.me/klmpkfsvpn/1)`;

    const opts = {
        reply_markup: {
            inline_keyboard: [
                [{ text: '🛒 Beli Paket', callback_data: 'menu_list' }, { text: '💰 Isi Saldo', callback_data: 'menu_topup' }],
                [{ text: '🔍 Cek Kuota', callback_data: 'menu_cekkouta' }, { text: '📜 Riwayat', callback_data: 'menu_history' }],
                [{ text: '🔐 Login XL', callback_data: 'menu_xl_login' }, { text: '📊 Info XL', callback_data: 'menu_xl_info' }],
                [{ text: '👑 Upgrade Reseller', callback_data: 'menu_reseller' }, { text: '📦 Ganti Akun / Logout XL', callback_data: 'logout_xl' }],
                [{ text: '👨‍👩‍👧‍👦 Cek Akrab', callback_data: 'menu_cek_akrab' }, { text: '🎁 Referral', callback_data: 'menu_referral' }],
                [{ text: '📖 Panduan Bot', callback_data: 'menu_panduan' }], // Tombol baru untuk panduan
                [{ text: '🏆 Top Transaksi', callback_data: 'owner_leaderboard' }], // Cek transaksi terbanyak
                [{ text: '👤 Owner Panel', callback_data: 'menu_owner' }, { text: '👤 Profil', callback_data: 'menu_profile' }]
            ]
        }
    };

    try {
        if (messageId) {
            // Menggunakan editMessageCaption karena menu utama ada gambarnya
            return await bot.editMessageCaption(menuMsg, {
                chat_id: chatId,
                message_id: messageId,
                reply_markup: opts.reply_markup,
                parse_mode: 'Markdown'
            });
        } else {
            const logoPath = './logo.jpg';
            if (fs.existsSync(logoPath)) {
                return await bot.sendPhoto(chatId, fs.createReadStream(logoPath), {
                    caption: menuMsg,
                    parse_mode: 'Markdown',
                    reply_markup: opts.reply_markup
                });
            } else {
                return await bot.sendMessage(chatId, menuMsg, {
                    parse_mode: 'Markdown',
                    reply_markup: opts.reply_markup
                });
            }
        }
    } catch (e) { console.error("Error Menu Utama:", e.message); }
};
// ==========================================
// 4. CALLBACK QUERY HANDLER (FINAL COMPLETE VERSION)
// ==========================================
bot.on('callback_query', async (callback) => {
    const chatId = callback.message.chat.id;
    const messageId = callback.message.message_id;
    const data = callback.data;
    const userId = callback.from.id;
    const userData = getUserData(userId);

    try {
        // --- 1. NAVIGASI UTAMA ---
        if (data === 'back_to_menu') {
            await sendMainMenu(chatId, userId, callback.from.first_name, messageId);
        }

        // --- 2. MENU LIST KATEGORI ---
        else if (data === 'menu_list') {
            await bot.editMessageCaption('📂 *PILIH KATEGORI PAKET*:', {
                chat_id: chatId, message_id: messageId,
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '💎 BEST SELLER', callback_data: 'cat_bestseller' }, { text: '⚡ XTRA COMBO', callback_data: 'cat_combo' }],
                        [{ text: '👨‍👩‍👧‍👦 XL AKRAB', callback_data: 'cat_akrab' }, { text: '🔥 HOTROD', callback_data: 'cat_hotrod' }],
                        [{ text: '🌐 SEMUA PAKET', callback_data: 'cat_all' }], 
                        [{ text: '📊 CEK STOK AKRAB', callback_data: 'menu_stok_akrab' }],
                        [{ text: '🔙 KEMBALI', callback_data: 'back_to_menu' }]
                    ]
                },
                parse_mode: 'Markdown'
            });
        }

       // =========================================================
        // 3. LOGIKA LIST PAKET & KATEGORI (FIXED & CLEAN)
        // =========================================================
        else if (data.startsWith('cat_')) {
            const [ , kategori, pageStr] = data.split('_');
            const page = parseInt(pageStr) || 0;
            const itemsPerPage = 5;

            try {
                // 1. Ambil data dari API Pusat
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                let filtered = res.data.data;

                // 2. Filter Kategori
                if (kategori === 'bestseller') {
                    filtered = filtered.filter(p => /edukasi|conference|iflix|xtra kuota/i.test(p.package_name));
                } else if (kategori === 'akrab') {
                    filtered = filtered.filter(p => p.package_name.toLowerCase().includes('akrab'));
                } else if (kategori === 'combo') {
                    filtered = filtered.filter(p => p.package_name.toLowerCase().includes('combo'));
                } else if (kategori === 'hotrod') {
                    filtered = filtered.filter(p => p.package_name.toLowerCase().includes('hotrod'));
                }

                const totalPages = Math.ceil(filtered.length / itemsPerPage);
                const paginatedItems = filtered.slice(page * itemsPerPage, (page + 1) * itemsPerPage);

                // 3. Logika Role & Harga (Pembulatan ke atas agar tidak ada desimal)
                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                const roleIcon = userData.role === 'reseller' ? "💎 RESELLER" : "👤 MEMBER";

                let pText = `📦 *KATEGORI: ${kategori.toUpperCase()}*\n`;
                pText += `🎭 *TIPE AKUN:* ${roleIcon}\n`;
                pText += `📖 *HALAMAN:* ${page + 1}/${totalPages}\n━━━━━━━━━━━━━━━━━━\n\n`;

                const inlineKeyboard = [];

                paginatedItems.forEach(p => {
                    // Menggunakan Math.ceil untuk memastikan harga bulat sempurna (Integer)
                    const hargaJual = Math.ceil(p.package_harga_int + markup);
                    
                    // Cek jika ada deskripsi, jika tidak ada pakai teks default
                    const deskripsi = p.package_description && p.package_description.trim() !== "" 
                        ? p.package_description 
                        : "Metode tembak otomatis (Dor). Proses cepat 1-5 menit.";

                    pText += `🔹 *${p.package_name}*\n`;
                    pText += `📝 _${deskripsi}_\n`;
                    pText += `💰 *${formatRupiah(hargaJual)}*\n──────────────────\n`;
                    
                    inlineKeyboard.push([{ 
                        text: `🛒 BELI | ${formatRupiah(hargaJual)}`, 
                        callback_data: `buy_direct_${p.package_code}` 
                    }]);
                });

                // 4. Navigasi Halaman
                const nav = [];
                if (page > 0) nav.push({ text: '⬅️ Prev', callback_data: `cat_${kategori}_${page - 1}` });
                if ((page + 1) * itemsPerPage < filtered.length) nav.push({ text: 'Next ➡️', callback_data: `cat_${kategori}_${page + 1}` });
                
                if (nav.length > 0) inlineKeyboard.push(nav);
                inlineKeyboard.push([{ text: '🔙 KEMBALI KE MENU', callback_data: 'menu_list' }]);

                await bot.editMessageCaption(pText, { 
                    chat_id: chatId, 
                    message_id: messageId, 
                    parse_mode: 'Markdown', 
                    reply_markup: { inline_keyboard: inlineKeyboard } 
                });

            } catch (err) {
                console.error("Error Fetching Data:", err.message);
                bot.answerCallbackQuery(callback.id, { text: "❌ Gagal memuat data dari pusat. Coba lagi nanti." });
            }
        }

        // =========================================================
        // 4. LOGIKA TOMBOL BELI (PROTEKSI SALDO MODAL)
        // =========================================================
        else if (data.startsWith('buy_direct_')) {
            const code = data.replace('buy_direct_', '');
            await bot.answerCallbackQuery(callback.id, { text: "⏳ Mengecek ketersediaan..." });

            try {
                // 1. Cek Saldo Modal KMSP secara Real-time
                const resSaldo = await axios.get(`https://golang-openapi-panelaccountbalance-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                const saldoModal = resSaldo.data.data.balance || resSaldo.data.balance;

                // 2. Ambil data paket yang dipilih
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                const p = res.data.data.find(x => x.package_code === code);
                
                if (!p) return bot.sendMessage(chatId, "❌ Paket tidak ditemukan.");

                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                const hargaJual = p.package_harga_int + markup;

                // 3. VALIDASI: Jika Saldo Modal KMSP (Pusat) < Harga Modal Paket
                if (saldoModal < p.package_harga_int) {
                    return bot.sendMessage(chatId, `⚠️ *STOK SEDANG RE-FILL*\n\nMohon maaf Bos, saldo modal admin di pusat sedang menipis (${formatRupiah(saldoModal)}).\n\nSilakan pilih paket lain yang lebih murah atau hubungi Admin.`);
                }
                
                // Simpan order sementara
                tempOrder[chatId] = { 
                    package_code: code, 
                    price_sell: hargaJual, 
                    name: p.package_name 
                };

                // --- FITUR AUTOFILL / GANTI AKUN ---
                if (userBalance[userId].saved_phone) {
                    // Jika ada nomor tersimpan, kasih pilihan mau lanjut atau ganti
                    tempOrder[chatId].phone = userBalance[userId].saved_phone;
                    
                    await bot.sendMessage(chatId, `🛒 *ORDER:* ${p.package_name}\n💰 *HARGA:* ${formatRupiah(hargaJual)}\n📱 *NOMOR:* \`${tempOrder[chatId].phone}\`\n\nNomor ditemukan! Ingin menggunakan nomor ini lagi?`, {
                        parse_mode: 'Markdown',
                        reply_markup: {
                            inline_keyboard: [
                                [{ text: '✅ YA, LANJUTKAN', callback_data: 'confirm_buy' }],
                                [{ text: '🔄 GANTI NOMOR', callback_data: 'logout_xl_direct' }]
                            ]
                        }
                    });
                } else {
                    // Jika belum ada nomor (Habis Logout), minta input nomor baru
                    userState[chatId] = 'WAITING_BUY_PHONE';
                    await bot.sendMessage(chatId, `🛒 *ORDER:* ${p.package_name}\n💰 *HARGA:* ${formatRupiah(hargaJual)}\n\n👉 *Masukkan NOMOR HP (XL):*`, { parse_mode: 'Markdown' });
                }

            } catch (e) {
                console.error(e);
                bot.sendMessage(chatId, "⚠️ Terjadi gangguan koneksi ke server pusat.");
            }
        }

        // Logika Logout Cepat saat klik "Ganti Nomor" di menu beli
        else if (data === 'logout_xl_direct') {
            userBalance[userId].saved_phone = null;
            saveDB(config.userBalanceFile, userBalance);
            userState[chatId] = 'WAITING_BUY_PHONE';
            await bot.editMessageText("🔄 *NOMOR DIRESET*\n\n👉 Sekarang masukkan **NOMOR HP (XL)** baru:", { 
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown' 
            });
        }

        // --- 5. TOPUP SALDO ---
        else if (data === 'menu_topup') {
            userState[chatId] = 'WAITING_TOPUP_AMOUNT';
            await bot.sendMessage(chatId, '💰 *ISI SALDO OTOMATIS*\n\nMasukkan nominal Topup (Min. 1.000):');
        }
        else if (data === 'check_payment') {
            const order = tempOrder[chatId];
            if (!order || order.type !== 'topup') return bot.sendMessage(chatId, '❌ Sesi expired.');
            const res = await axios.get(`https://my-payment.autsc.my.id/api/status/payment`, { params: { transaction_id: order.trx_id, apikey: config.apiKeyPayment } });
            if (res.data.paid) {
                userBalance[userId].balance += order.amount_added;
                saveDB(config.userBalanceFile, userBalance);
                delete tempOrder[chatId];
                await bot.sendMessage(chatId, `✅ *TOPUP BERHASIL*\nSaldo masuk: ${formatRupiah(order.amount_added)}`);
            } else {
                bot.answerCallbackQuery(callback.id, { text: "⏳ Belum ada pembayaran." });
            }
        }

        // --- 6. UPGRADE & REFERRAL ---
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
            
            // Bonus Referral jika ada pengajak
            if (userData.referredBy && userBalance[userData.referredBy]) {
                userBalance[userData.referredBy].balance += config.bonusReferralUpgrade;
                bot.sendMessage(userData.referredBy, `💰 *BONUS REFERRAL!*\nTeman Anda upgrade reseller. Saldo +${formatRupiah(config.bonusReferralUpgrade)}`);
            }
            
            saveDB(config.userBalanceFile, userBalance);
            await bot.sendMessage(chatId, "🎉 *SUKSES!* Sekarang Anda adalah RESELLER.");
        }
        else if (data === 'menu_referral') {
            const link = `https://t.me/${config.botUsername}?start=${userId}`;
            await bot.sendMessage(chatId, `🎁 *REFERRAL*\nDapatkan *${formatRupiah(config.bonusReferralUpgrade)}* setiap teman upgrade Reseller!\n\nLink kamu:\n\`${link}\``, { parse_mode: 'Markdown' });
        }

        // --- 7. XL TOOLS (CEK KUOTA, AKRAB, LOGIN) ---
        else if (data === 'menu_cekkouta') {
            userState[chatId] = 'WAITING_CHECK_QUOTA';
            await bot.sendMessage(chatId, '🔍 *CEK KUOTA*\nMasukkan nomor XL (08xx):');
        }
        else if (data === 'menu_cek_akrab') {
            userState[chatId] = 'WAITING_CEK_AKRAB';
            await bot.sendMessage(chatId, '👨‍👩‍👧‍👦 *CEK AKRAB*\nMasukkan nomor XL pengelola:');
        }
// --- CEK STOK AKRAB & CIRCLE (VERSI AUTH SIDOMPUL) ---
        else if (data === 'menu_stok_akrab') {
            await bot.answerCallbackQuery(callback.id, { text: "🔍 Menghubungi Server Sidompul..." });
            
            try {
                await bot.editMessageCaption("⏳ *MENGHUBUNGI SERVER SIDOMPUL...*\nSedang memproses autentikasi dan cek stok.", {
                    chat_id: chatId, message_id: messageId, parse_mode: 'Markdown'
                }).catch(() => {});

                const res = await axios.get(`https://golang-openapi-checkpackagestockakrabglobal-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP },
                    headers: {
                        "Authorization": config.sidompulAuth, // Pastikan ini Bearer xxxxxx
                        "X-API-Key": config.sidompulKey,
                        "X-App-Version": "4.0.0"
                    },
                    timeout: 40000 // Beri waktu lebih lama (40 detik)
                });

                if (res.data && res.data.data) {
                    const dataStok = res.data.data;
                    let txt = `📊 *STOK LIVE SIDOMPUL*\n━━━━━━━━━━━━━━━━━━\n\n`;
                    const kb = [];

                    dataStok.forEach(p => {
                        txt += `✅ *${p.package_name}*\n`;
                        // Jika ada info sisa stok/limit dari API, bisa ditambah di sini
                        txt += `📝 Status: Available\n\n`;
                        
                        kb.push([{ 
                            text: `🛒 BELI: ${p.package_name.split(' ')[0]}...`, 
                            callback_data: `buy_direct_${p.package_code}` 
                        }]);
                    });

                    kb.push([{ text: '🔙 KEMBALI', callback_data: 'menu_list' }]);

                    await bot.editMessageCaption(txt, { 
                        chat_id: chatId, message_id: messageId, 
                        parse_mode: 'Markdown', reply_markup: { inline_keyboard: kb } 
                    });
                } else {
                    await bot.sendMessage(chatId, "⚠️ *STOK TIDAK DITEMUKAN*\nRespon sukses tapi data kosong. Mungkin stok regional sedang habis.");
                }

            } catch (e) {
                console.error("Error Detail Sidompul:", e.response ? e.response.data : e.message);
                
                let detailError = "Koneksi Terputus.";
                if (e.response && e.response.status === 401) detailError = "Auth Sidompul Expired (Minta OTP lagi).";
                if (e.response && e.response.status === 403) detailError = "X-API-Key Salah.";
                
                await bot.sendMessage(chatId, `⚠️ *AUTENTIKASI GAGAL*\n\nDetail: ${detailError}\n_Pastikan login Sidompul masih aktif._`);
            }
        }
        else if (data === 'menu_xl_login') {
            userState[chatId] = 'WAITING_XL_PHONE';
            await bot.sendMessage(chatId, '🔐 *LOGIN XL*\nMasukkan nomor XL untuk OTP:');
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
// --- MENU RIWAYAT (FIXED) ---
        else if (data === 'menu_history') {
            try {
                // Ambil 5 riwayat terakhir milik user tersebut
                const myHistory = historyTrx
                    .filter(h => String(h.userId) === String(userId))
                    .slice(-5)
                    .reverse();

                if (myHistory.length === 0) {
                    return bot.sendMessage(chatId, "📜 *BELUM ADA RIWAYAT*\n\nAnda belum pernah melakukan transaksi paket.", { parse_mode: 'Markdown' });
                }

                let hText = "📜 *5 RIWAYAT TERAKHIR*\n━━━━━━━━━━━━━━━━━━\n\n";
                myHistory.forEach((h, i) => {
                    const statusEmoji = h.status === 'SUCCESS' ? '✅' : '❌';
                    const tanggal = h.date ? h.date.split('T')[0] : '-';
                    
                    hText += `${i + 1}. ${statusEmoji} *${h.product}*\n`;
                    hText += `   📱 No: \`${h.phone || '-'}\`\n`;
                    hText += `   💰 ${formatRupiah(h.price)} | 📅 ${tanggal}\n`;
                    hText += `──────────────────\n`;
                });

                await bot.sendMessage(chatId, hText, { parse_mode: 'Markdown' });
            } catch (err) {
                console.error("Error Riwayat:", err);
                bot.sendMessage(chatId, "⚠️ Gagal memuat riwayat.");
            }
        }
        // --- 8. KONFIRMASI PEMBAYARAN PAKET (WITH AUTO-SAVE & AUTO-UPGRADE) ---
        else if (data === 'confirm_buy') {
            const order = tempOrder[chatId];
            if (!order) return bot.sendMessage(chatId, "❌ Sesi habis.");
            if (userData.balance < order.price_sell) return bot.sendMessage(chatId, "❌ Saldo kurang.");
            if (isProcessing[chatId]) return;

            isProcessing[chatId] = true;
            try {
                await bot.editMessageText("⏳ *SEDANG DIPROSES...*", { chat_id: chatId, message_id: messageId });
                const res = await axios.get(`https://golang-openapi-packagepurchase-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, phone: order.phone, package_code: order.package_code }
                });

                if (res.data && res.data.status) {
                    // 1. Potong Saldo User & Simpan Nomor HP (Auto-Login)
                    userBalance[userId].balance -= order.price_sell;
                    userBalance[userId].saved_phone = order.phone; 

                    // 2. 🔥 TRACKER TRANSAKSI 🔥
                    userBalance[userId].total_trx = (userBalance[userId].total_trx || 0) + 1;
                    const currentTrx = userBalance[userId].total_trx;

                    // 3. 🎁 LOGIKA REWARD (TIAP 20 TRX)
                    if (currentTrx % 20 === 0) {
                        const bonus = 2000;
                        userBalance[userId].balance += bonus;
                        bot.sendMessage(userId, `🎉 *BONUS CAIR!* Saldo +${formatRupiah(bonus)} karena sudah mencapai ${currentTrx} transaksi!`);
                    }

                    // 4. 💎 LOGIKA AUTO-UPGRADE RESELLER (TIAP 50 TRX)
                    if (currentTrx >= 50 && userBalance[userId].role !== 'reseller') {
                        userBalance[userId].role = 'reseller';
                        bot.sendMessage(userId, `🎊 *SELAMAT!* Anda resmi menjadi **RESELLER**!\nSekarang Anda mendapatkan harga lebih murah di setiap paket.`);
                        bot.sendMessage(config.ownerId, `🚀 *UPGRADE ROLE:* User ${userId} otomatis jadi Reseller.`);
                    }

                    // 5. Simpan ke Database
                    historyTrx.push({ userId, date: new Date().toISOString(), product: order.name, price: order.price_sell, status: 'SUCCESS', phone: order.phone });
                    saveDB(config.userBalanceFile, userBalance);
                    saveDB(config.historyFile, historyTrx);
// 6. Kirim Nota Sukses ke User
                    await bot.sendMessage(chatId, `✅ *SUKSES!*\n📦 ${order.name}\n📱 ${order.phone}\n💰 Sisa Saldo: ${formatRupiah(userBalance[userId].balance)}\n\n_Nomor HP ini telah disimpan untuk transaksi berikutnya._`);

                    // --- TAMBAHAN: NOTIFIKASI KE GRUP ---
                    if (config.notifGroupId) {
                        const textGrup = `
🔔 *TRANSAKSI BARU*
━━━━━━━━━━━━━━━━━━
👤 *Pembeli:* ${callback.from.first_name}
📦 *Produk:* ${order.name}
📱 *Nomor:* \`${order.phone}\`
💰 *Harga:* ${formatRupiah(order.price_sell)}
🎭 *Role:* ${userData.role.toUpperCase()}
━━━━━━━━━━━━━━━━━━
Status: *BERHASIL (LUNAS)*
`;
                        await bot.sendMessage(config.notifGroupId, textGrup, { parse_mode: 'Markdown' }).catch(e => console.log("Gagal kirim ke grup:", e.message));
                    }
                    // ----------------------------------

                    delete tempOrder[chatId];
                    
                } else {
                    await bot.sendMessage(chatId, `❌ Gagal: ${res.data.message}`);
                }
            } catch (e) { 
                bot.sendMessage(chatId, "⚠️ Gangguan Server"); 
            } finally { 
                delete isProcessing[chatId]; 
            }
        }

        // --- OWNER PANEL (UPDATE) ---
        else if (data === 'menu_owner') {
            if (userId !== config.ownerId) return;
            await bot.editMessageCaption("👑 *OWNER DASHBOARD*\n\nKelola modal dan user Anda di sini:", {
                chat_id: chatId, message_id: messageId,
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '💰 Saldo Supplier', callback_data: 'owner_cek_saldo_kmsp' }], // Tombol Baru
                        [{ text: '➕ Tambah Saldo', callback_data: 'owner_add_saldo' }, { text: '🎭 Set Role', callback_data: 'owner_set_role' }],
                        [{ text: '📢 Broadcast', callback_data: 'owner_broadcast' }],
                        [{ text: '🗑️ Reset Riwayat', callback_data: 'owner_reset_history' }],
                        [{ text: '🏠 Menu Utama', callback_data: 'back_to_menu' }]
                    ]
                }
            });
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
// --- RESET RIWAYAT TRANSAKSI ---
        else if (data === 'owner_reset_history') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "❌ Akses Ditolak" });
            
            // Memunculkan peringatan sebelum menghapus
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
            
            // Mengosongkan memori riwayat
            historyTrx.length = 0; 
            
            // Menyimpan memori yang sudah kosong ke file database history.json
            saveDB(config.historyFile, historyTrx);
            
            await bot.editMessageCaption("🗑️ *RIWAYAT BERHASIL DIHAPUS*\n\nSemua data riwayat transaksi lama yang berantakan telah dibersihkan. Database riwayat sekarang kosong seperti baru.", {
                chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [[{ text: '🔙 Kembali ke Panel Owner', callback_data: 'menu_owner' }]]
                }
            });
        }
// --- CEK SALDO SUPPLIER KMSP (VERSI API TERBARU) ---
        else if (data === 'owner_cek_saldo_kmsp') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(callback.id, { text: "Akses Ditolak" });
            
            await bot.answerCallbackQuery(callback.id, { text: "🔍 Menghubungi Server KMSP..." });
            
            try {
                // Menggunakan Endpoint yang baru kamu kasih
                const res = await axios.get(`https://golang-openapi-panelaccountbalance-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP },
                    timeout: 20000 
                });
                
                // Biasanya struktur respon KMSP itu res.data.data.balance atau res.data.balance
                // Kita buat proteksi agar tidak error kalau strukturnya beda
                const dataKMSP = res.data.data || res.data;
                const saldoPusat = dataKMSP.balance;

                if (saldoPusat !== undefined) {
                    let peringatan = saldoPusat < 50000 ? "\n\n⚠️ *PERINGATAN:* Saldo menipis, segera isi ulang!" : "";

                    await bot.editMessageCaption(`💰 *SALDO MODAL KMSP*\n━━━━━━━━━━━━━━━━━━\n\nSisa Saldo Anda:\n*${formatRupiah(saldoPusat)}*${peringatan}\n\n_Update terakhir: ${new Date().toLocaleString('id-ID')}_`, {
                        chat_id: chatId, 
                        message_id: messageId, 
                        parse_mode: 'Markdown',
                        reply_markup: {
                            inline_keyboard: [
                                [{ text: '🔄 Refresh Saldo', callback_data: 'owner_cek_saldo_kmsp' }],
                                [{ text: '🔙 Kembali', callback_data: 'menu_owner' }]
                            ]
                        }
                    });
                } else {
                    await bot.sendMessage(chatId, `❌ *GAGAL:* Struktur data API berubah atau API Key salah.`);
                }
            } catch (e) {
                console.error("Error Detail:", e.message);
                await bot.sendMessage(chatId, `⚠️ *SERVER BUSY*\n\nDetail: Tidak ada respon dari KMSP. Coba lagi nanti.`);
            }
        }
// --- 🏆 FITUR LEADERBOARD (TOP SPENDER) ---
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
// --- FITUR LOGOUT / GANTI NOMOR XL ---
        else if (data === 'logout_xl') {
            await bot.answerCallbackQuery(callback.id, { text: "Memproses Logout..." });

            // Menghapus nomor XL yang tersimpan di database user
            if (userBalance[userId]) {
                userBalance[userId].saved_phone = null; // Menghapus data nomor
                saveDB(config.userBalanceFile, userBalance);
                
                const pesanLogout = `✅ *LOGOUT BERHASIL*\n━━━━━━━━━━━━━━━━━━\n\nNomor XL kamu telah dihapus dari sistem. Saat melakukan pembelian berikutnya, kamu akan diminta memasukkan nomor baru.\n\n_Silakan kembali ke menu utama._`;
                
                await bot.editMessageCaption(pesanLogout, {
                    chat_id: chatId, message_id: messageId, parse_mode: 'Markdown',
                    reply_markup: { inline_keyboard: [[{ text: '🏠 MENU UTAMA', callback_data: 'back_to_menu' }]] }
                });
            }
        }
    } catch (err) {
        console.error("Callback Error:", err);
    }
    bot.answerCallbackQuery(callback.id).catch(() => {});
});

// ==========================================
// 5. MESSAGE HANDLER (Chat Logic) - FIXED
// ==========================================
bot.on('message', async (msg) => {
    const chatId = msg.chat.id;
    const userId = msg.from.id;
    const text = msg.text;

    // Abaikan jika bukan private chat atau tidak ada teks
    if (msg.chat.type !== 'private' || !text) return;

    if (text === '/backup' && userId === config.ownerId) {
        if (fs.existsSync(config.userBalanceFile)) await bot.sendDocument(chatId, config.userBalanceFile);
        if (fs.existsSync(config.historyFile)) await bot.sendDocument(chatId, config.historyFile);
        return;
    }

    // --- STATE HANDLER ---
    const state = userState[chatId];
    if (!state) return; 

    try {
        // FLOW BELI PAKET
        if (state === 'WAITING_BUY_CODE') {
            const code = text.toUpperCase().trim();
            const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
            const p = res.data.data.find(x => x.package_code === code);
            
            if (!p) return bot.sendMessage(chatId, '❌ *Kode paket tidak ditemukan.*\nSilakan masukkan kode yang benar atau cek menu List Paket.');
            
            const userData = getUserData(userId);
            const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
            const finalPrice = p.package_harga_int + markup;
            
            tempOrder[chatId] = { package_code: code, price_server: p.package_harga_int, price_sell: finalPrice, name: p.package_name };
            userState[chatId] = 'WAITING_BUY_PHONE';
            
            await bot.sendMessage(chatId, `✅ *Paket Terpilih:*\n📦 ${p.package_name}\n💰 Harga: ${formatRupiah(finalPrice)}\n\nKirim *NOMOR TUJUAN* (Contoh: 0878xxx):`, { parse_mode: 'Markdown' });
        }

        else if (state === 'WAITING_BUY_PHONE') {
    let phone = text.replace(/[^0-9]/g, '');
    if (phone.startsWith('08')) phone = '62' + phone.slice(1);
    if (phone.length < 10) return bot.sendMessage(chatId, "❌ Nomor tidak valid.");

    const userData = getUserData(userId);
    const order = tempOrder[chatId];
    order.phone = phone;

    // Hitung sisa saldo
    const sisaSaldo = userData.balance - order.price_sell;
    
    // Reset state agar bot tidak bingung
    delete userState[chatId];
    
    const receipt = 
        `🧾 *RINGKASAN PESANAN*\n` +
        `━━━━━━━━━━━━━━━━━━\n` +
        `📦 *Produk* : ${order.name}\n` +
        `📱 *Nomor* : \`${order.phone}\`\n` +
        `💰 *Harga* : *${formatRupiah(order.price_sell)}*\n` +
        `━━━━━━━━━━━━━━━━━━\n` +
        `👤 *Saldo Anda* : ${formatRupiah(userData.balance)}\n` +
        `📉 *Sisa Saldo* : _${formatRupiah(sisaSaldo)}_\n` +
        `━━━━━━━━━━━━━━━━━━\n` +
        `⚠️ _Pastikan nomor sudah benar. Transaksi yang sudah diproses tidak dapat dibatalkan._`;
    
    await bot.sendMessage(chatId, receipt, {
        parse_mode: 'Markdown',
        reply_markup: { 
            inline_keyboard: [
                [{ text: '✅ BAYAR SEKARANG', callback_data: 'confirm_buy' }],
                [{ text: '❌ BATALKAN', callback_data: 'back_to_menu' }]
            ] 
        }
    });
}

        // FLOW TOPUP
        else if (state === 'WAITING_TOPUP_AMOUNT') {
            // 1. Bersihkan input (hanya ambil angka)
            const nominal = parseInt(text.replace(/[^0-9]/g, ''));
            
            // 2. Validasi nominal
            if (isNaN(nominal) || nominal < 1000 || nominal > 2000000) {
                return bot.sendMessage(chatId, "❌ *Nominal tidak valid!*\nMinimal Topup: Rp 1.000\nMaksimal Topup: Rp 2.000.000", { parse_mode: 'Markdown' });
            }

            // 3. Reset state & Ambil data user agar aman
            delete userState[chatId];
            const userData = getUserData(userId);
            const loading = await bot.sendMessage(chatId, "⏳ *Sedang menyiapkan metode pembayaran...*", { parse_mode: 'Markdown' });

            try {
                // 4. Panggil API Payment
                const res = await axios.get(`https://my-payment.autsc.my.id/api/deposit`, { 
                    params: { 
                        amount: nominal, 
                        apikey: config.apiKeyPayment 
                    } 
                });

                // Hapus loading
                await bot.deleteMessage(chatId, loading.message_id).catch(() => {});

                if (res.data.status === 'success') {
                    const payData = res.data.data;

                    // 5. SIMPAN DATA LENGKAP KE TEMP_ORDER (BIAR PLONG!)
                    tempOrder[chatId] = { 
                        type: 'topup', 
                        trx_id: payData.id, 
                        amount_requested: nominal,
                        amount_to_pay: payData.total_amount, // Nominal + Kode unik
                        user_id: userId,
                        current_balance: userData.balance
                    };

                    // 6. Tampilkan Struk QRIS yang Mewah
                    const captionTopup = 
                        `💳 *TAGIHAN TOPUP SALDO*\n` +
                        `━━━━━━━━━━━━━━━━━━\n` +
                        `🆔 *Order ID* : \`${payData.id}\`\n` +
                        `👤 *Pengguna* : ${msg.from.first_name}\n` +
                        `💰 *Nominal* : ${formatRupiah(nominal)}\n` +
                        `➕ *Kode Unik* : ${formatRupiah(payData.total_amount - nominal)}\n` +
                        `━━━━━━━━━━━━━━━━━━\n` +
                        `💵 *TOTAL BAYAR* : *${formatRupiah(payData.total_amount)}*\n` +
                        `━━━━━━━━━━━━━━━━━━\n\n` +
                        `👇 *Cara Bayar:*\n` +
                        `1. Screenshot QRIS di atas.\n` +
                        `2. Scan di Aplikasi Dana, OVO, QRIS atau M-Banking.\n` +
                        `3. Masukkan nominal *PERSIS* sesuai Total Bayar.\n\n` +
                        `⏳ _Saldo akan masuk otomatis setelah pembayaran terdeteksi._`;

                    await bot.sendPhoto(chatId, payData.qris_url, {
                        caption: captionTopup,
                        parse_mode: 'Markdown',
                        reply_markup: { 
                            inline_keyboard: [
                                [{ text: '🔄 Cek Status Pembayaran', callback_data: 'check_payment' }], 
                                [{ text: '🔙 Batal', callback_data: 'back_to_menu' }]
                            ] 
                        }
                    });
                } else {
                    bot.sendMessage(chatId, "❌ Server payment sedang sibuk. Coba lagi nanti.");
                }

            } catch (e) {
                console.error("Error API Topup:", e);
                await bot.deleteMessage(chatId, loading.message_id).catch(() => {});
                bot.sendMessage(chatId, "❌ Gagal membuat QRIS. Pastikan koneksi server aman.");
            }
        }

        // FLOW CEK KUOTA / AKRAB
        else if (state === 'WAITING_CHECK_QUOTA') {
    let phone = text.replace(/[^0-9]/g, '');
    if (phone.startsWith('0')) phone = '62' + phone.slice(1);
    
    delete userState[chatId];
    await bot.sendMessage(chatId, '🔍 *Sedang mengecek kuota ke server...*', { parse_mode: 'Markdown' });

    try {
        // Gunakan domain apigw.kmsp-store.com jika itu yang dulu berhasil
        const res = await axios.get(`https://apigw.kmsp-store.com/sidompul/v4/cek_kuota`, { 
            params: { msisdn: phone, isJSON: 'true' }, 
            headers: { 
                "Authorization": config.sidompulAuth, 
                "X-API-Key": config.sidompulKey,
                "X-App-Version": "4.0.0" 
            },
            timeout: 20000
        });

        if (res.data.status && res.data.data.hasil) {
            const hasil = res.data.data.hasil
                .replace(/<br>/g, "\n")
                .replace(/📃 RESULT:/g, "📊 *HASIL CEK KUOTA*");
            
            await bot.sendMessage(chatId, hasil, { 
                parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '🏠 Menu Utama', callback_data: 'back_to_menu' }]] }
            });
        } else {
            await bot.sendMessage(chatId, '❌ *Data tidak ditemukan.*\nNomor salah atau sedang gangguan server.');
        }
    } catch(e) { 
        console.error(e.message);
        bot.sendMessage(chatId, '❌ *Gagal terhubung ke provider.*'); 
    }
}
        else if (state === 'WAITING_CEK_AKRAB') {
    let phone = text.replace(/[^0-9]/g, '');
    if (phone.startsWith('0')) phone = '62' + phone.slice(1);
    
    delete userState[chatId];
    await bot.sendMessage(chatId, '🔍 *Sedang mengecek status paket Akrab...*', { parse_mode: 'Markdown' });

    try {
        // Samakan URL-nya dengan Cek Kuota yang sudah berhasil tadi
        const res = await axios.get(`https://apigw.kmsp-store.com/sidompul/v4/cek_akrab`, { 
            params: { msisdn: phone, isJSON: 'true' }, 
            headers: { 
                "Authorization": config.sidompulAuth, 
                "X-API-Key": config.sidompulKey,
                "X-App-Version": "4.0.0" 
            },
            timeout: 20000
        });

        if (res.data.status && res.data.data.hasil) {
            const hasil = res.data.data.hasil
                .replace(/<br>/g, "\n")
                .replace(/📃 RESULT:/g, "📊 *HASIL CEK AKRAB*");
            
            await bot.sendMessage(chatId, hasil, { 
                parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '🏠 Menu Utama', callback_data: 'back_to_menu' }]] }
            });
        } else {
            await bot.sendMessage(chatId, '❌ *Data tidak ditemukan.*');
        }
    } catch(e) { 
        bot.sendMessage(chatId, '❌ *Gagal terhubung ke provider.*'); 
    }
}
        // FLOW XL LOGIN (OTP)
        else if (state === 'WAITING_XL_PHONE') {
            let phone = text.replace(/[^0-9]/g, '');
            if (phone.startsWith('0')) phone = '62' + phone.slice(1);
            
            await bot.sendMessage(chatId, '⏳ *Meminta kode OTP...*', { parse_mode: 'Markdown' });
            try {
                const res = await axios.get(`https://golang-openapi-reqotp-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, phone: phone, method: 'OTP' }
                });
                if (res.data.status) {
                    tempOrder[chatId] = { auth_id: res.data.data.auth_id, phone: phone };
                    userState[chatId] = 'WAITING_XL_OTP';
                    await bot.sendMessage(chatId, '✅ *OTP Terkirim!*\nSilakan masukkan kode OTP yang masuk ke SMS kamu:');
                } else {
                    delete userState[chatId];
                    await bot.sendMessage(chatId, `❌ *Gagal:* ${res.data.message}`);
                }
            } catch (e) { bot.sendMessage(chatId, "❌ Gagal request OTP."); }
        }
        else if (state === 'WAITING_XL_OTP') {
            const dataLogin = tempOrder[chatId];
            if (!dataLogin) return delete userState[chatId];
            
            await bot.sendMessage(chatId, '⏳ *Memverifikasi...*', { parse_mode: 'Markdown' });
            try {
                const res = await axios.get(`https://golang-openapi-login-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, phone: dataLogin.phone, method: 'OTP', auth_id: dataLogin.auth_id, otp: text.trim() }
                });
                if (res.data.status) {
                    xlSessions[userId] = { phone: dataLogin.phone, access_token: res.data.data.access_token };
                    saveDB(config.xlSessionsFile, xlSessions);
                    delete userState[chatId]; delete tempOrder[chatId];
                    await bot.sendMessage(chatId, '✅ *LOGIN BERHASIL!*\nSekarang kamu bisa menggunakan menu Info XL.', { parse_mode: 'Markdown' });
                } else {
                    await bot.sendMessage(chatId, '❌ *OTP Salah atau Kadaluwarsa.*');
                }
            } catch (e) { bot.sendMessage(chatId, "❌ Gagal verifikasi."); }
        }

        // FLOW OWNER (TAMBAH SALDO)
        else if (state === 'OWNER_WAITING_ID_ADD') {
            const tId = text.trim();
            if (!userBalance[tId]) return bot.sendMessage(chatId, "❌ ID User tidak ditemukan.");
            tempOrder[chatId] = { targetId: tId };
            userState[chatId] = 'OWNER_WAITING_AMOUNT_ADD';
            await bot.sendMessage(chatId, `👤 User: ${tId}\n💰 *Masukkan nominal saldo:*`);
        }
        else if (state === 'OWNER_WAITING_AMOUNT_ADD') {
            const amount = parseInt(text);
            const tId = tempOrder[chatId].targetId;
            if (isNaN(amount)) return bot.sendMessage(chatId, "❌ Nominal harus angka.");
            
            userBalance[tId].balance += amount;
            saveDB(config.userBalanceFile, userBalance);
            delete userState[chatId]; delete tempOrder[chatId];
            
            await bot.sendMessage(chatId, `✅ Berhasil menambahkan ${formatRupiah(amount)} ke ID ${tId}`);
            bot.sendMessage(tId, `🎁 *Saldo Masuk!*\nAdmin telah menambahkan saldo sebesar ${formatRupiah(amount)} ke akunmu.`).catch(()=>{});
        }

        // FLOW OWNER (BROADCAST)
        else if (state === 'OWNER_WAITING_BC_TEXT') {
            delete userState[chatId];
            const users = Object.keys(userBalance);
            await bot.sendMessage(chatId, `🚀 *Memulai Broadcast ke ${users.length} pengguna...*`, { parse_mode: 'Markdown' });
            
            users.forEach((uid, idx) => {
                setTimeout(() => {
                    bot.sendMessage(uid, `📢 *INFORMASI ADMIN*\n━━━━━━━━━━━━━━━━━━\n\n${text}`, { parse_mode: 'Markdown' })
                    .catch((err) => console.log(`Gagal kirim ke ${uid}: ${err.message}`));
                }, idx * 150); 
            });
        }

        // FLOW OWNER (SET ROLE)
        else if (state === 'OWNER_WAITING_ID_ROLE') {
            const tId = text.trim();
            if (!userBalance[tId]) {
                return bot.sendMessage(chatId, "❌ *ID Salah atau User belum terdaftar.*", { parse_mode: 'Markdown' });
            }
            
            delete userState[chatId];
            await bot.sendMessage(chatId, `👤 *User ID:* \`${tId}\`\n\nSilakan pilih role baru untuk user tersebut:`, {
                parse_mode: 'Markdown',
                reply_markup: { 
                    inline_keyboard: [
                        [
                            { text: 'Member', callback_data: `setrole_${tId}_member` }, 
                            { text: 'Reseller', callback_data: `setrole_${tId}_reseller` }
                        ],
                        [{ text: '❌ Batal', callback_data: 'back_to_menu' }]
                    ] 
                }
            });
        }

    } catch (e) {
        console.error("Error Message Handler:", e);
        delete userState[chatId]; // Hapus state biar gak stuck kalau error
        bot.sendMessage(chatId, "❌ *Terjadi kesalahan sistem.* Silakan coba lagi.");
    }
});

// ==========================================
// 6. ERROR HANDLING (Anti-Crash)
// ==========================================
process.on('uncaughtException', (err) => {
    console.error('CRITICAL ERROR:', err);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('UNHANDLED REJECTION:', reason);
});

// STARTUP LOG
console.log('🤖 BOT AKTIF!');
console.log(`📅 Started: ${new Date().toLocaleString()}`);