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
    try {
        if (!fs.existsSync(file)) {
            fs.writeFileSync(file, JSON.stringify(defaultVal, null, 2));
            return defaultVal;
        }
        return JSON.parse(fs.readFileSync(file));
    } catch (e) { return defaultVal; }
};

const saveDB = (file, data) => fs.writeFileSync(file, JSON.stringify(data, null, 2));

// Inisialisasi Database
let userBalance = loadDB(config.userBalanceFile, {}); 
let historyTrx = loadDB(config.historyFile, []);
let xlSessions = loadDB(config.xlSessionsFile, {});

const userState = {}; 
const tempOrder = {}; 
const isProcessing = {}; 

const formatRupiah = (n) => new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', minimumFractionDigits: 0 }).format(n);

const getUserData = (userId, referrerId = null) => {
    if (!userBalance[userId]) {
        userBalance[userId] = { 
            balance: 0, 
            role: 'member',
            referredBy: (referrerId && String(referrerId) !== String(userId)) ? String(referrerId) : null 
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
    return `${d}h ${h}j ${m}m`;
};

// ==========================================
// 3. TAMPILAN DASHBOARD
// ==========================================
const sendMainMenu = async (chatId, userId, name, messageId = null) => {
    const userData = getUserData(userId);
    const totalUsers = Object.keys(userBalance).length;
    let totalTrxPrice = historyTrx.reduce((a, b) => a + (b.price || 0), 0);

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
👥 User: ${totalUsers} | 🌍 TRX: ${formatRupiah(totalTrxPrice)}
───────────────────
☀️ [ADMIN](https://t.me/AJW29) ☀️ [GRUP](https://t.me/klmpkfsvpn)`; 

    const opts = {
        parse_mode: 'Markdown',
        disable_web_page_preview: true,
        reply_markup: {
            inline_keyboard: [[{ text: '🛠️ BUKA MENU FITUR', callback_data: 'menu_semua_fitur' }]]
        }
    };

    if (messageId) return bot.editMessageText(menuMsg, { chat_id: chatId, message_id: messageId, ...opts }).catch(()=>{});
    bot.sendMessage(chatId, menuMsg, opts);
};

// ==========================================
// 4. CALLBACK HANDLER (SATU KESATUAN)
// ==========================================
bot.on('callback_query', async (clb) => {
    const { id, data, from, message } = clb;
    const chatId = message.chat.id;
    const userId = from.id;
    const userData = getUserData(userId);

    try {
        if (data === 'menu_semua_fitur') {
            const featureMsg = "🛠️ *PUSAT FITUR FANTUNNEL*\nSilakan pilih fitur yang ingin digunakan:";
            const featureOpts = {
                chat_id: chatId,
                message_id: message.message_id,
                parse_mode: 'Markdown',
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '🛒 Beli Paket', callback_data: 'menu_beli' }, { text: '💰 Isi Saldo', callback_data: 'menu_topup' }],
                        [{ text: '🔍 Cek Kuota', callback_data: 'menu_cekkouta' }, { text: '📜 Riwayat', callback_data: 'menu_history' }],
                        [{ text: '🔐 Login XL', callback_data: 'menu_xl_login' }, { text: '📊 Info XL', callback_data: 'menu_xl_info' }],
                        [{ text: '👑 Upgrade Reseller', callback_data: 'menu_reseller' }, { text: '📦 List Paket', callback_data: 'menu_list' }],
                        [{ text: '🎁 Referral', callback_data: 'menu_referral' }, { text: '👤 Owner', callback_data: 'menu_owner' }],
                        [{ text: '🏠 Kembali', callback_data: 'back_to_menu' }]
                    ]
                }
            };
            return bot.editMessageText(featureMsg, featureOpts);
        }

        if (data === 'menu_beli') {
            userState[chatId] = 'WAITING_BUY_CODE';
            bot.sendMessage(chatId, '🛒 *BELI PAKET*\nKirimkan *KODE PAKET* (Contoh: XTRA1):');
        }

        else if (data === 'menu_list') {
            bot.sendMessage(chatId, '📂 *PILIH KATEGORI PAKET*:', {
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '💎 BEST SELLER', callback_data: 'cat_bestseller_0' }],
                        [{ text: '👨‍👩‍👧‍👦 XL AKRAB', callback_data: 'cat_akrab_0' }, { text: '⚡ XTRA COMBO', callback_data: 'cat_combo_0' }],
                        [{ text: '🏠 MENU', callback_data: 'back_to_menu' }]
                    ]
                }
            });
        }

        else if (data.startsWith('cat_')) {
            const [_, kategori, pageStr] = data.split('_');
            const page = parseInt(pageStr);
            try {
                const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
                const items = res.data.data;
                const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
                
                let filtered = items.slice(page * 10, (page + 1) * 10);
                let pText = `📦 *DAFTAR PAKET* (Hal ${page+1})\n\n`;
                
                filtered.forEach(p => {
                    pText += `🔹 *${p.package_name}*\n   Kode: \`${p.package_code}\`\n   Harga: *${formatRupiah(p.package_harga_int + markup)}*\n\n`;
                });

                bot.editMessageText(pText, {
                    chat_id: chatId,
                    message_id: message.message_id,
                    parse_mode: 'Markdown',
                    reply_markup: {
                        inline_keyboard: [
                            [{ text: '⬅️ Prev', callback_data: `cat_${kategori}_${page > 0 ? page - 1 : 0}` }, { text: 'Next ➡️', callback_data: `cat_${kategori}_${page + 1}` }],
                            [{ text: '🏠 KEMBALI', callback_data: 'back_to_menu' }]
                        ]
                    }
                });
            } catch (e) { bot.sendMessage(chatId, "❌ Gagal ambil data API."); }
        }

        else if (data === 'menu_history') {
            const myHistory = historyTrx.filter(h => h.userId === userId).slice(-5);
            if (myHistory.length === 0) return bot.sendMessage(chatId, "📜 Belum ada transaksi.");
            let hText = "📜 *5 TRANSAKSI TERAKHIR*\n\n";
            myHistory.forEach((h, i) => { hText += `${i+1}. ${h.product}\n   Status: ${h.status} | ${formatRupiah(h.price)}\n\n`; });
            bot.sendMessage(chatId, hText, { parse_mode: 'Markdown' });
        }

        else if (data === 'menu_owner') {
            if (userId !== config.ownerId) return bot.answerCallbackQuery(id, { text: "❌ Akses Ditolak" });
            bot.editMessageText("👑 *OWNER DASHBOARD*", {
                chat_id: chatId,
                message_id: message.message_id,
                reply_markup: {
                    inline_keyboard: [
                        [{ text: '➕ Tambah Saldo', callback_data: 'owner_add_saldo' }],
                        [{ text: '📢 Broadcast', callback_data: 'owner_broadcast' }],
                        [{ text: '🏠 Kembali', callback_data: 'back_to_menu' }]
                    ]
                }
            });
        }

        else if (data === 'owner_add_saldo') {
            userState[chatId] = 'OWNER_WAITING_ID_ADD';
            bot.sendMessage(chatId, "Kirimkan ID Telegram User yang akan ditambah saldonya:");
        }

        else if (data === 'confirm_buy') {
            const order = tempOrder[chatId];
            if (isProcessing[chatId]) return bot.answerCallbackQuery(id, { text: "⚠️ Transaksi sedang diproses..." });
            if (!order || userData.balance < order.price_sell) return bot.sendMessage(chatId, '❌ Saldo tidak cukup.');

            isProcessing[chatId] = true;
            userBalance[userId].balance -= order.price_sell;
            saveDB(config.userBalanceFile, userBalance);

            bot.sendMessage(chatId, "🚀 *Memproses transaksi...*", { parse_mode: 'Markdown' });

            try {
                const res = await axios.get(`https://golang-openapi-packagepurchase-xltembakservice.kmsp-store.com/v1`, {
                    params: { api_key: config.apiKeyKMSP, package_code: order.package_code, phone: order.phone, price_or_fee: order.price_server }
                });

                if (res.data.status) {
                    historyTrx.push({ date: new Date(), userId, product: order.name, price: order.price_sell, status: 'SUKSES' });
                    saveDB(config.historyFile, historyTrx);
                    bot.sendMessage(chatId, `✅ *SUKSES!*\nProduk: ${order.name}\nNomor: ${order.phone}`, { parse_mode: 'Markdown' });
                } else {
                    userBalance[userId].balance += order.price_sell;
                    saveDB(config.userBalanceFile, userBalance);
                    bot.sendMessage(chatId, `❌ *GAGAL:* ${res.data.message}`);
                }
            } catch (e) {
                userBalance[userId].balance += order.price_sell;
                saveDB(config.userBalanceFile, userBalance);
                bot.sendMessage(chatId, "❌ Error Provider. Saldo di-refund.");
            } finally {
                delete isProcessing[chatId];
                delete tempOrder[chatId];
            }
        }

        else if (data === 'back_to_menu') {
            delete userState[chatId];
            sendMainMenu(chatId, userId, from.first_name, message.message_id);
        }

        bot.answerCallbackQuery(id).catch(() => {});
    } catch (e) { console.log(e); }
});

// ==========================================
// 5. MESSAGE HANDLER (INPUT TEKS)
// ==========================================
bot.on('message', async (msg) => {
    const chatId = msg.chat.id;
    const userId = msg.from.id;
    const text = msg.text;

    if (!text || msg.chat.type !== 'private') return;

    // Handle Commands
    if (text.startsWith('/start')) {
        const referrerId = text.split(' ')[1];
        getUserData(userId, referrerId);
        return sendMainMenu(chatId, userId, msg.from.first_name);
    }

    const state = userState[chatId];
    const userData = getUserData(userId);

    // Logic per State
    try {
        if (state === 'WAITING_BUY_CODE') {
            tempOrder[chatId] = { package_code: text.toUpperCase().trim() };
            userState[chatId] = 'WAITING_BUY_PHONE';
            bot.sendMessage(chatId, `✅ Kode: ${text}\nKirim *NOMOR XL (08xxx)*:`, { parse_mode: 'Markdown' });
        } 
        
        else if (state === 'WAITING_BUY_PHONE') {
            let phone = text.replace(/[^0-9]/g, '');
            if (phone.startsWith('0')) phone = '62' + phone.slice(1);
            const code = tempOrder[chatId].package_code;

            bot.sendMessage(chatId, "🔍 Cek paket...");
            const res = await axios.get(`https://golang-openapi-packagelist-xltembakservice.kmsp-store.com/v1?api_key=${config.apiKeyKMSP}`);
            const p = res.data.data.find(x => x.package_code === code);

            if (!p) {
                delete userState[chatId];
                return bot.sendMessage(chatId, "❌ Kode paket salah.");
            }

            const markup = userData.role === 'reseller' ? config.markupReseller : config.markupMember;
            const finalPrice = p.package_harga_int + markup;

            tempOrder[chatId] = { ...tempOrder[chatId], phone, price_server: p.package_harga_int, price_sell: finalPrice, name: p.package_name };
            delete userState[chatId];

            bot.sendMessage(chatId, `📦 *KONFIRMASI*\n\nProduk: ${p.package_name}\nNomor: ${phone}\nHarga: *${formatRupiah(finalPrice)}*`, {
                parse_mode: 'Markdown',
                reply_markup: { inline_keyboard: [[{ text: '✅ BELI SEKARANG', callback_data: 'confirm_buy' }], [{ text: '❌ BATAL', callback_data: 'back_to_menu' }]] }
            });
        }

        else if (state === 'OWNER_WAITING_ID_ADD') {
            const targetId = text.trim();
            if (!userBalance[targetId]) return bot.sendMessage(chatId, "❌ ID tidak ditemukan.");
            tempOrder[chatId] = { targetId };
            userState[chatId] = 'OWNER_WAITING_AMOUNT_ADD';
            bot.sendMessage(chatId, `Target ID: ${targetId}\nMasukkan nominal saldo:`);
        }

        else if (state === 'OWNER_WAITING_AMOUNT_ADD') {
            const amount = parseInt(text.replace(/[^0-9]/g, ''));
            const targetId = tempOrder[chatId].targetId;
            userBalance[targetId].balance += amount;
            saveDB(config.userBalanceFile, userBalance);
            delete userState[chatId];
            bot.sendMessage(chatId, `✅ Berhasil menambah ${formatRupiah(amount)} ke ID ${targetId}`);
            bot.sendMessage(targetId, `🎁 Saldo kamu ditambah oleh Admin sebesar ${formatRupiah(amount)}`);
        }
        
        else if (state === 'WAITING_TOPUP_AMOUNT') {
            const nominal = parseInt(text.replace(/[^0-9]/g, ''));
            if (nominal < 1000) return bot.sendMessage(chatId, "❌ Minimal Rp 1.000");
            delete userState[chatId];
            const res = await axios.get(`https://my-payment.autsc.my.id/api/deposit`, { params: { amount: nominal, apikey: config.apiKeyPayment } });
            if (res.data.status === 'success') {
                bot.sendPhoto(chatId, res.data.data.qris_url, { caption: `💰 *QRIS TOPUP*\nTotal: ${formatRupiah(res.data.data.total_amount)}\n\nScan untuk membayar.`, parse_mode: 'Markdown' });
            }
        }
    } catch (e) { console.log(e); }
});

console.log('Bot Fantunnel V2 Fixed Ready! 🚀');
