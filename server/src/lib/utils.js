import fs from "fs";
import path from "path";

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

export const deleteFileImage = (filePath) => {
  try {
    if (!filePath) return;
    const fullPath = path.join(process.cwd(), "public", filePath);
    if (fs.existsSync(fullPath)) {
      fs.unlinkSync(fullPath);
    }
  } catch (error) {
    // ponytail: silent fail on delete, file gone = OK
  }
};
