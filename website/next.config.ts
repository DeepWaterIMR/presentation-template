import type { NextConfig } from "next";

const githubPages = process.env.GITHUB_PAGES === "true";
const assetPrefix = githubPages ? "/presentation-template" : "";

const nextConfig: NextConfig = {
  output: "export",
  trailingSlash: true,
  assetPrefix,
  images: {
    unoptimized: true,
  },
};

export default nextConfig;
