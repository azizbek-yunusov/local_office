import type { Metadata } from "next";
import { PropsWithChildren } from "react";

export const metadata: Metadata = {};

export default function Layout({ children }: PropsWithChildren<{}>) {
  return <>{children}</>;
}
