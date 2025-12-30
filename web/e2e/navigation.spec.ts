import { test, expect, waitForTurbo } from "./fixtures";

test.describe("Navigation", () => {
  test("home page shows dashboard", async ({ page }) => {
    await page.goto("/");

    // Dashboard should be accessible at root
    await expect(page).toHaveURL("/");
  });

  test("navigation links work", async ({ page }) => {
    await page.goto("/");

    const nav = page.locator("nav");

    // Navigate to Search (Organizations)
    await nav.getByRole("link", { name: "Search" }).click();
    await waitForTurbo(page);
    await expect(page).toHaveURL(/organizations/);

    // Navigate to Commands
    await nav.getByRole("link", { name: "Commands" }).click();
    await waitForTurbo(page);
    await expect(page).toHaveURL(/commands/);

    // Navigate to Exports
    await nav.getByRole("link", { name: "Exports" }).click();
    await waitForTurbo(page);
    await expect(page).toHaveURL(/exports/);

    // Navigate to Dashboard
    await nav.getByRole("link", { name: "Dashboard" }).click();
    await waitForTurbo(page);
    await expect(page).toHaveURL("/");
  });

  test("header shows application name", async ({ page }) => {
    await page.goto("/organizations");

    await expect(page.getByRole("link", { name: /Page Migration/ })).toBeVisible();
  });
});
