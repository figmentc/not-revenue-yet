import "../src/styles.css";

export const metadata = {
  metadataBase: new URL("https://not-revenue-yet.austinhan.chatgpt.site"),
  title: "Not Revenue Yet — Proof before pursuit",
  description: "A proof-first Codex plugin that verifies paid opportunities and counts money only after settlement.",
  openGraph: {
    title: "Not Revenue Yet",
    description: "A listing is a claim. Cash is a fact.",
    type: "website"
  },
  twitter: {
    card: "summary",
    title: "Not Revenue Yet",
    description: "A listing is a claim. Cash is a fact."
  }
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
