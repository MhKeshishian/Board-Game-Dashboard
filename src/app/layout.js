import "./globals.css";
import "react-grid-layout/css/styles.css";
import "react-resizable/css/styles.css";

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
