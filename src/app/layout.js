import "./globals.css";
import "react-grid-layout/css/styles.css";
import "react-resizable/css/styles.css";
import Navbar from "@/components/Navbar/Navbar";

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        <Navbar />
        {children}
      </body>
    </html>
  );
}
