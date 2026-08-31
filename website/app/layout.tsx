import type { Metadata } from "next";
import "./globals.css";

const siteUrl = "https://deepwaterimr.github.io/presentation-template/";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "Presentation Template | DeepWaterIMR",
  description: "An AI-friendly Quarto presentation starter with reproducible figures and a complete scientific slide-pattern library.",
  icons: {
    icon: "favicon.svg",
  },
  openGraph: {
    type: "website",
    url: siteUrl,
    title: "Presentation Template",
    description: "Choose the proof. Then choose the slide.",
    images: [{ url: "og.png", width: 1730, height: 909, alt: "Presentation Template — Choose the proof. Then choose the slide." }],
  },
  twitter: {
    card: "summary_large_image",
    title: "Presentation Template",
    description: "Choose the proof. Then choose the slide.",
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
