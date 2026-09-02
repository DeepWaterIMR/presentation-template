import type { Metadata } from "next";
import "./globals.css";

const siteUrl = "https://deepwaterimr.github.io/presentation-template/";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "Presentation Template | DeepWaterIMR",
  description: "A Quarto template with predefined layouts and reproducible figure workflows for academic presentations.",
  icons: {
    icon: "favicon.svg",
  },
  openGraph: {
    type: "website",
    url: siteUrl,
    title: "Presentation Template",
    description: "Predefined Quarto layouts for scientific claims, figures, tables, and explanations.",
    images: [{ url: "og.png", width: 1200, height: 630, alt: "Abstract bathymetric illustration for the DeepWaterIMR presentation template" }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Presentation Template",
    description: "Predefined Quarto layouts for scientific claims, figures, tables, and explanations.",
    images: ["og.png"],
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
