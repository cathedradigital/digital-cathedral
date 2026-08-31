import { createFileRoute } from "@tanstack/react-router";
import App from "@/App";

export const Route = createFileRoute("/")({
  ssr: false,
  head: () => ({
    meta: [
      { title: "Catedra Digital — Bíblia, Catecismo e Oração" },
      {
        name: "description",
        content:
          "Leia a Bíblia, estude o Catecismo, reze o terço e cresça na fé com a Catedra Digital: sua plataforma católica completa.",
      },
      { property: "og:title", content: "Catedra Digital — Bíblia, Catecismo e Oração" },
      {
        property: "og:description",
        content:
          "Leia a Bíblia, estude o Catecismo, reze o terço e cresça na fé com a Catedra Digital: sua plataforma católica completa.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: App,
});
