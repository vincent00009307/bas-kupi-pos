import type { Metadata, Viewport } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "BAS KUPI POS", description: "Sistem kasir dan manajemen Warung Kopi BAS KUPI", manifest: "/manifest.webmanifest", appleWebApp: { capable: true, statusBarStyle: "black-translucent", title: "BAS KUPI" } };
export const viewport: Viewport = { themeColor: "#17110d", width: "device-width", initialScale: 1 };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="id"><body>{children}</body></html>; }
