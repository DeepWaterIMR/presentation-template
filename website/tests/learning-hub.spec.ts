import { expect, test } from "@playwright/test";

test("catalogue, deep links, dialog, copy, and responsive layout", async ({ page }, testInfo) => {
  const failedResponses: string[] = [];
  page.on("response", (response) => {
    if (response.status() >= 400) failedResponses.push(`${response.status()} ${response.url()}`);
  });

  await page.goto("/presentation-template/");
  await expect(page).toHaveTitle("Presentation Template | DeepWaterIMR");
  await expect(page.getByRole("heading", { level: 1 })).toHaveText("Choose the proof. Then choose the slide.");

  const cards = page.locator(".pattern-card");
  await expect(cards).toHaveCount(21);
  const previewImages = page.locator(".pattern-image img");
  for (let index = 0; index < await previewImages.count(); index += 1) {
    const preview = previewImages.nth(index);
    await preview.scrollIntoViewIfNeeded();
    await expect.poll(async () => preview.evaluate((image) => (image as HTMLImageElement).complete && (image as HTMLImageElement).naturalWidth > 0), { timeout: 15_000 }).toBe(true);
  }
  await expect.poll(async () => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);

  const sampler = page.getByRole("link", { name: /Open sampler/i }).first();
  const samplerHref = await sampler.getAttribute("href");
  expect(samplerHref).toBeTruthy();
  const samplerResponse = await page.request.get(new URL(samplerHref!, page.url()).href);
  expect(samplerResponse.ok()).toBe(true);

  await page.getByLabel("Search slide patterns").fill("map");
  await expect(cards).toHaveCount(2);
  const mapCard = page.getByRole("button", { name: "Inspect Balanced map layout" });
  await mapCard.focus();
  await expect(mapCard).toBeFocused();
  expect(await mapCard.evaluate((element) => getComputedStyle(element).outlineStyle)).not.toBe("none");
  await page.keyboard.press("Enter");

  const dialog = page.getByRole("dialog");
  await expect(dialog).toBeVisible();
  await expect(dialog.getByRole("heading", { name: "Balanced map layout" })).toBeVisible();
  await expect(page).toHaveURL(/#pattern\/map-layout$/);
  await expect(dialog.getByAltText("Rendered example of Balanced map layout")).toBeVisible();
  const copyButton = dialog.getByRole("button", { name: "Copy" });
  if (testInfo.project.name === "mobile") {
    await copyButton.focus();
    await page.keyboard.press("Enter");
  } else {
    await copyButton.click();
  }
  await expect(dialog.getByText("Pattern source copied to the clipboard.")).toHaveText("Pattern source copied to the clipboard.");
  expect(await page.evaluate(() => navigator.clipboard.readText())).toContain("#map-layout");
  await page.keyboard.press("Escape");
  await expect(dialog).toBeHidden();
  await expect(mapCard).toBeFocused();

  await page.goto("/presentation-template/#pattern/background-art");
  await expect(page.getByRole("dialog")).toBeVisible();
  await expect(page.getByRole("heading", { name: "Decorative background art" })).toBeVisible();
  await page.keyboard.press("Escape");
  await page.getByLabel("Search slide patterns").fill("");
  await page.getByRole("button", { name: "Decision", exact: true }).click();
  await expect(cards).toHaveCount(3);

  await page.emulateMedia({ reducedMotion: "reduce" });
  const transitionDuration = await page.locator(".pattern-card").first().evaluate((element) => getComputedStyle(element).transitionDuration);
  expect(transitionDuration).toMatch(/0\.00001s|1e-05s|0s/);
  await expect.poll(async () => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
  expect(failedResponses).toEqual([]);

  await page.screenshot({ path: testInfo.outputPath("learning-hub.png"), fullPage: true });
});
