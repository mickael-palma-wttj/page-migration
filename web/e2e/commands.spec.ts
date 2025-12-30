import { test, expect, waitForTurbo } from "./fixtures";

test.describe("Commands", () => {
  test("displays command history page", async ({ page }) => {
    await page.goto("/commands");

    await expect(page).toHaveTitle(/Commands/);
    await expect(page.getByRole("heading", { name: "Command History" })).toBeVisible();
    await expect(page.getByRole("link", { name: "Run Command" })).toBeVisible();
  });

  test("shows command tabs", async ({ page }) => {
    await page.goto("/commands");

    const tabs = page.locator(".border-b.border-wttj-gray-light");
    await expect(tabs.getByRole("link", { name: "All" })).toBeVisible();
    await expect(tabs.getByRole("link", { name: "Extract", exact: true })).toBeVisible();
    await expect(tabs.getByRole("link", { name: "Export", exact: true })).toBeVisible();
    await expect(tabs.getByRole("link", { name: "Migrate", exact: true })).toBeVisible();
  });

  test("filters commands by tab", async ({ page }) => {
    await page.goto("/commands");

    const tabs = page.locator(".border-b.border-wttj-gray-light");
    await tabs.getByRole("link", { name: "Extract", exact: true }).click();
    await waitForTurbo(page);

    await expect(page).toHaveURL(/tab=extract/);
  });

  test("navigates to new command page", async ({ page }) => {
    await page.goto("/commands");

    await page.getByRole("link", { name: "Run Command" }).click();
    await waitForTurbo(page);

    await expect(page).toHaveURL(/commands\/new/);
    await expect(page.getByRole("heading", { name: /Run Command|New Command/ })).toBeVisible();
  });
});
