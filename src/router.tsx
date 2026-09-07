import { QueryClient } from "@tanstack/react-query";
import { createRouter as createRouterBase } from "@tanstack/react-router";

// O projeto legado roda sem strictNullChecks; o tipo público de createRouter
// exige essa flag. Mantemos o comportamento em runtime e relaxamos o tipo.
const createRouter = createRouterBase as unknown as (opts: any) => any;
import { routeTree } from "./routeTree.gen";

export const getRouter = () => {
  const queryClient = new QueryClient();

  const router = createRouter({
    routeTree,
    context: { queryClient },
    scrollRestoration: true,
    defaultPreloadStaleTime: 0,
  });

  return router;
};
