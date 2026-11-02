# Session 4 writes its prioritizr code out in full, so test the session's own objects:
# run its chunks once (plots to a null device) and check the plans they produce.
.libPaths(c(file.path(normalizePath(testthat::test_path("..")), "Rlib"), .libPaths()))
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
code <- withr::local_tempfile(fileext = ".R")
knitr::purl(file.path(root, "04-scp.Rmd"), output = code, quiet = TRUE)
s4 <- new.env()
withr::with_dir(root, withr::with_envvar(c(WORKSHOP_NO_MCP = "1"), {
  grDevices::pdf(NULL)
  suppressMessages(sys.source(code, envir = s4))
  grDevices::dev.off()
}))

test_that("Red List weights: 13 species have no status and get weight 1; the dhole gets 4", {
  w <- s4$w_redlist
  expect_equal(nrow(w), 108)
  expect_false(anyNA(w$weight))
  st <- s4$status
  expect_equal(sum(is.na(st$iucn) & is.na(st$china_red_list)), 13)
  expect_equal(w$weight[w$species == "Cuon alpinus"], 4)       # Endangered
})

test_that("every plan covers every site once and stays within its budget", {
  check <- function(plan, cost, budget) {
    expect_equal(nrow(plan), 101)
    expect_setequal(plan$Site, s4$sites$Site)
    expect_lte(sum(cost$cost[match(plan$Site[plan$selected], cost$Site)]), budget + 1e-6)
  }
  check(s4$plan_equal, s4$cost_equal, s4$budget_frac * 101)
  check(s4$plan_redlist, s4$cost_equal, s4$budget_frac * 101)
  check(s4$plan_cost, s4$cost_human, s4$budget_human)
  check(s4$plan_wild, s4$cost_human, s4$budget_human)
})

test_that("costing by human modification picks less modified sites, and more of them", {
  hm <- function(plan) s4$sites$Human_modification_1km[match(plan$Site[plan$selected], s4$sites$Site)]
  expect_lt(mean(hm(s4$plan_cost)), mean(hm(s4$plan_redlist)))
  expect_gt(sum(s4$plan_cost$selected), sum(s4$plan_redlist$selected))
})

test_that("livestock are left out of the wild plan", {
  expect_true(all(c("Bos taurus", "Bubalus bubalis", "Capra hircus") %in% s4$status$species[s4$status$local_status == "dom"]))
  expect_equal(sum(s4$w_wild$weight > 0), 108 - sum(s4$status$local_status == "dom"))
})

test_that("raising a species' weight never lowers its coverage up to the target", {
  # Above the target the objective does not reward more coverage, so compare capped coverage,
  # and pick a species that starts below its target so the comparison means something.
  cv0 <- s4$coverage(s4$plan_equal)
  sp <- cv0$species[which.min(cv0$held)]
  expect_lt(min(cv0$held), s4$target)
  boosted <- s4$w_equal
  boosted$weight[boosted$species == sp] <- 100
  cv1 <- s4$coverage(s4$make_plan(boosted, s4$cost_equal, s4$budget_frac * 101))
  expect_gte(min(cv1$held[cv1$species == sp], s4$target), min(cv0$held[cv0$species == sp], s4$target) - 1e-9)
})

test_that("make_plan gives the same plan as the step-by-step code", {
  expect_identical(s4$make_plan(s4$w_equal, s4$cost_equal, s4$budget_frac * 101)$selected, s4$plan_equal$selected)
})
