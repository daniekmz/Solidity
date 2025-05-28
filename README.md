Submitted for verification
(ENOKI)
https://basescan.org/token/0xBCfc96e61F3f5AF6Fd19C6560Cf28494c594D12C
(BaseOwl)
https://basescan.org/address/0x350784f500166e9d68f4bd2d2616f575fea68b08

# Panduan Deploy BaseOwl Token di Remix untuk Base Chain

## 🚀 Persiapan Awal

### 1. Setup Wallet & Base Network
- **Pastikan MetaMask terpasang** di browser Anda
- **Tambahkan Base network** ke MetaMask:
  - Network Name: `Base`
  - RPC URL: `https://mainnet.base.org`
  - Chain ID: `8453`
  - Currency Symbol: `ETH`
  - Block Explorer: `https://basescan.org`

### 2. Siapkan ETH untuk Gas Fee
- Anda perlu ETH di Base network untuk deploy
- Bridge ETH dari Ethereum mainnet ke Base menggunakan [Base Bridge](https://bridge.base.org)
- Minimal 0.001-0.01 ETH sudah cukup untuk deploy

## 📝 Langkah Deploy di Remix

### Step 1: Buka Remix IDE
1. Kunjungi [remix.ethereum.org](https://remix.ethereum.org)
2. Buat file baru: `BaseOwl.sol`
3. Copy-paste kode kontrak lengkap

### Step 2: Compile Kontrak
1. Klik tab **"Solidity Compiler"** (ikon Solidity)
2. Pilih compiler version: `0.8.0` atau lebih tinggi
3. Klik **"Compile BaseOwl.sol"**
4. Pastikan tidak ada error (hijau ✅)

### Step 3: Setup Deployment
1. Klik tab **"Deploy & Run Transactions"** (ikon Ethereum)
2. Pilih Environment: **"Injected Provider - MetaMask"**
3. Pastikan account dan network sudah benar (Base)

### Step 4: Isi Parameter Deploy
Masukkan parameter berikut di bagian constructor:

```
NAME_            : "BaseOwl Token"
SYMBOL_          : "BOWL"
INITIALSUPPLY_   : 1000000000000000000000000000
TOKENOWNER       : 0xAlamatWalletAnda...
FEERECEIVER      : 0xAlamatPenerimaBiaya...
```

**Penjelasan Parameter:**
- `name_`: Nama token (contoh: "BaseOwl Token")
- `symbol_`: Symbol token (contoh: "BOWL")
- `initialSupply_`: Total supply dalam wei (1000000000 = 1 miliar token)
- `tokenOwner`: Alamat yang akan menerima ownership dan initial supply
- `feeReceiver`: Alamat yang menerima biaya deploy (bisa sama dengan tokenOwner)

### Step 5: Deploy Kontrak
1. Klik **"Deploy"**
2. MetaMask akan muncul untuk konfirmasi transaksi
3. Periksa gas fee dan klik **"Confirm"**
4. Tunggu hingga transaksi confirmed (biasanya 1-5 menit)

## ⚙️ Konfigurasi Setelah Deploy

### 1. Verifikasi Deployment
```javascript
// Cek di bagian "Deployed Contracts" di Remix
// Atau kunjungi Basescan dengan contract address
```

### 2. Setup Burn Mechanism
Setelah deploy berhasil, konfigurasi burn mechanism:

#### A. Set Burn Rate (Opsional - default 1%)
```solidity
setBurnRate(200)  // 2% burn rate (200 basis points)
```

#### B. Tambahkan Swap Pairs
```solidity
// Contoh untuk Uniswap V2 pair
setSwapPair("0xAlamatPairContract", true)
```

#### C. Set Burn Exemptions
```solidity
// Exempt liquidity pool atau marketing wallet
setBurnExemption("0xAlamatWallet", true)
```

## 🔍 Cara Menemukan Swap Pair Address

### Untuk Uniswap di Base:
1. Buat liquidity pool di [Uniswap](https://app.uniswap.org)
2. Setelah add liquidity, cari pair contract address
3. Bisa juga cek di Basescan dengan search: "Uniswap V2 Pair"

### Manual Calculation:
```solidity
// Factory Uniswap V2 di Base: 0x8909Dc15e40173Ff4699343b6eB8132c65e18eC6
// Gunakan CREATE2 address calculation
```

## 💡 Tips Penting

### Gas Optimization
- Deploy saat network tidak sibuk (gas lebih murah)
- Set gas limit manual jika perlu: ~2,000,000 gas
- Gunakan gas price yang reasonable

### Security Checklist
- ✅ Verifikasi alamat tokenOwner dan feeReceiver
- ✅ Double-check initial supply (hati-hati dengan decimal)
- ✅ Test di testnet dulu jika memungkinkan
- ✅ Backup private key dan contract address

### Setelah Deploy
1. **Verify Contract** di Basescan untuk transparansi
2. **Add Liquidity** di DEX (Uniswap, SushiSwap, dll)
3. **Set Swap Pairs** untuk aktivasi burn mechanism
4. **Test Transfer** untuk memastikan burn berfungsi

## 🛠️ Troubleshooting

### Error Umum:
- **"Gas estimation failed"**: Tingkatkan gas limit
- **"Insufficient funds"**: Tambah ETH untuk gas
- **"Contract creation failed"**: Cek parameter constructor
- **"Revert"**: Periksa alamat feeReceiver valid

### Jika Deploy Gagal:
1. Cek saldo ETH di Base network
2. Refresh Remix dan coba lagi
3. Reset MetaMask transaction nonce jika stuck
4. Coba dengan gas price lebih tinggi

## 📊 Monitoring & Management

### Track Contract:
- Bookmark contract address di Basescan
- Monitor burn events dan total supply
- Track holder distribution

### Management Functions:
- `setBurnRate()`: Adjust burn percentage
- `setSwapPair()`: Add/remove DEX pairs
- `setBurnExemption()`: Manage exemptions
- `recoverERC20()`: Recover stuck tokens

---

**🎉 Selamat! Token BaseOwl Anda sudah berhasil di-deploy di Base network dengan burn mechanism yang siap digunakan!**
