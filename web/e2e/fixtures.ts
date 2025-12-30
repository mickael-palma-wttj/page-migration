import { test as base, expect } from "@playwright/test";

// Extend base test with custom fixtures
export const test = base.extend({
  // Add custom fixtures here if needed
});

export { expect };

// Helper to wait for Turbo navigation
export async function waitForTurbo(page: import("@playwright/test").Page) {
  await page.waitForFunction(() => {
    return !document.documentElement.hasAttribute("data-turbo-preview");
  });
}

// Helper to create test data via Rails console
export async function createCommandRun(options: {
  command: string;
  orgRef?: string;
  status?: string;
}) {
  const { execSync } = await import("child_process");
  const cmd = `bundle exec rails runner "CommandRun.create!(command: '${options.command}', org_ref: '${options.orgRef || ""}', status: '${options.status || "completed"}')"`;
  execSync(cmd, { cwd: process.cwd(), env: { ...process.env, RAILS_ENV: "test" } });
}
