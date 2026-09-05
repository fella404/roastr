export const formatIDR = (amount) =>
  `Rp ${amount.toLocaleString("id-ID")}`;

export const formatDate = (date) =>
  new Date(date).toLocaleDateString("id-ID", {
    day: "numeric",
    month: "long",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
  });
