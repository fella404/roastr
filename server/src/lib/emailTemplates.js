import { formatIDR, formatDate } from "./utils.js";

export const receiptTemplate = (transaction) => {
  const items = transaction.orderItems
    .map(
      (item) => `
      <tr>
        <td style="padding:8px 0;border-bottom:1px solid #eee;">
          ${item.productName}${item.variantName ? ` (${item.variantName})` : ""}
        </td>
        <td style="padding:8px 0;border-bottom:1px solid #eee;text-align:center;">${item.quantity}</td>
        <td style="padding:8px 0;border-bottom:1px solid #eee;text-align:right;">${formatIDR(item.unitPrice)}</td>
        <td style="padding:8px 0;border-bottom:1px solid #eee;text-align:right;">${formatIDR(item.subTotal)}</td>
      </tr>`
    )
    .join("");

  return `
    <div style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:24px;">
      <h2 style="text-align:center;color:#006241;">Roastr</h2>
      <p style="text-align:center;color:#666;margin:0;">Struk Pembelian</p>

      <hr style="border:none;border-top:1px solid #eee;margin:16px 0;" />

      <p style="margin:4px 0;"><strong>Pelanggan:</strong> ${transaction.customerName}</p>
      <p style="margin:4px 0;"><strong>Tanggal:</strong> ${formatDate(transaction.createdAt)}</p>
      <p style="margin:4px 0;"><strong>Tipe:</strong> ${transaction.orderType === "DINE_IN" ? "Dine-in" : "Takeaway"}</p>

      <hr style="border:none;border-top:1px solid #eee;margin:16px 0;" />

      <table style="width:100%;border-collapse:collapse;">
        <thead>
          <tr>
            <th style="text-align:left;padding:8px 0;border-bottom:2px solid #006241;">Item</th>
            <th style="text-align:center;padding:8px 0;border-bottom:2px solid #006241;">Qty</th>
            <th style="text-align:right;padding:8px 0;border-bottom:2px solid #006241;">Harga</th>
            <th style="text-align:right;padding:8px 0;border-bottom:2px solid #006241;">Subtotal</th>
          </tr>
        </thead>
        <tbody>
          ${items}
        </tbody>
      </table>

      <hr style="border:none;border-top:1px solid #eee;margin:16px 0;" />

      <table style="width:100%;">
        <tr>
          <td style="padding:4px 0;"><strong>Total</strong></td>
          <td style="padding:4px 0;text-align:right;"><strong>${formatIDR(transaction.totalPrice)}</strong></td>
        </tr>
        <tr>
          <td style="padding:4px 0;">Tunai</td>
          <td style="padding:4px 0;text-align:right;">${formatIDR(transaction.cashGiven)}</td>
        </tr>
        <tr>
          <td style="padding:4px 0;">Kembali</td>
          <td style="padding:4px 0;text-align:right;">${formatIDR(transaction.changeAmount)}</td>
        </tr>
      </table>

      <hr style="border:none;border-top:1px solid #eee;margin:16px 0;" />

      <p style="text-align:center;color:#999;font-size:12px;">Terima kasih atas kunjungan Anda!</p>
    </div>
  `;
};

export const otpTemplate = (code) => `
  <div style="font-family:sans-serif;max-width:480px;margin:0 auto;padding:24px;">
    <h2 style="text-align:center;color:#006241;">Roastr</h2>
    <p style="text-align:center;color:#666;">Reset Password</p>

    <hr style="border:none;border-top:1px solid #eee;margin:16px 0;" />

    <p style="color:#333;">Kode verifikasi Anda adalah:</p>

    <div style="text-align:center;margin:24px 0;">
      <span style="display:inline-block;font-size:32px;font-weight:bold;letter-spacing:8px;color:#006241;background:#f2f0eb;padding:16px 32px;border-radius:8px;">
        ${code}
      </span>
    </div>

    <p style="color:#666;font-size:14px;">Kode ini berlaku selama 10 menit. Jika Anda tidak meminta reset password, abaikan email ini.</p>

    <hr style="border:none;border-top:1px solid #eee;margin:16px 0;" />

    <p style="text-align:center;color:#999;font-size:12px;">Roastr POS System</p>
  </div>
`;
