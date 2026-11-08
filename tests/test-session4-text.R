# The numbers Session 4's prose states, checked against the session's own objects.
# If one of these fails, the sentence that quotes it needs rewriting, not just the test.
.libPaths(c(file.path(normalizePath(testthat::test_path("..")), "Rlib"), .libPaths()))
root <- normalizePath(testthat::test_path(".."), mustWork = TRUE)
code <- withr::local_tempfile(fileext = ".R")
knitr::purl(file.path(root, "04-scp.Rmd"), output = code, quiet = TRUE)
s4 <- new.env()
withr::with_dir(root, withr::with_envvar(c(WORKSHOP_NO_MCP = "1"), {
  grDevices::pdf(NULL)
  suppressMessages(capture.output(sys.source(code, envir = s4)))
  grDevices::dev.off()
}))
met <- function(plan, species = NULL) {
  cv <- s4$coverage(plan)
  if (!is.null(species)) cv <- cv[cv$species %in% species, ]
  sum(cv$held >= s4$target - 1e-9)
}

test_that("the inputs: 108 mammals, 101 sites, a 50% target and a 20% budget", {
  expect_equal(length(unique(s4$occ$species)), 108)
  expect_equal(nrow(s4$sites), 101)
  expect_equal(nrow(s4$occ), 10908)                     # "`occ` has 10,908 rows"
  expect_equal(nrow(s4$occ), 101 * 108)
  expect_equal(s4$target, 0.5)                          # "50% of a species' total"
  expect_equal(s4$budget_frac, 0.2)                     # "allowing 20% of them"
})

test_that("Plan 1: pu has 101 rows and 111 columns, 20 sites, 32 of 108 targets met", {
  expect_equal(nrow(s4$pu), 101)
  expect_equal(ncol(s4$pu), 111)
  expect_setequal(setdiff(names(s4$pu), s4$w_equal$species), c("Site", "cost", "id"))
  expect_equal(sum(s4$plan_equal$selected), 20)         # "which is 20 sites"
  expect_equal(met(s4$plan_equal), 32)                  # "Only 32 of the 108 species"
  expect_equal(nrow(s4$cov_equal), 108)
})

test_that("Plan 2: 13 species without status, 12 threatened, 17 of 20 shared, 3 to 4 targets met", {
  st <- s4$status
  expect_equal(sum(is.na(st$iucn) & is.na(st$china_red_list)), 13)
  expect_equal(length(s4$threatened), 12)               # "12 species get weight 3 or more"
  expect_equal(sum(s4$w_redlist$weight >= 3), 12)
  expect_equal(sum(s4$plan_redlist$selected), 20)
  shared <- sum(s4$plan_equal$selected & s4$plan_redlist$selected[match(s4$plan_equal$Site, s4$plan_redlist$Site)])
  expect_equal(shared, 17)                              # "share 17 of their 20 sites"
  expect_equal(20 - shared, 3)                          # "Swapping just 3 sites"
  expect_equal(met(s4$plan_equal, s4$threatened), 3)    # "from 3 to 4, out of 12"
  expect_equal(met(s4$plan_redlist, s4$threatened), 4)
})

test_that("Plan 3: same budget of 20.2, 32 sites, all 20 of Plan 2's kept", {
  ch <- function(plan) sum(s4$cost_human$cost[match(plan$Site[plan$selected], s4$cost_human$Site)])
  expect_equal(sum(s4$cost_human$cost), 101)                   # "all 101 sites together still cost 101"
  expect_equal(mean(s4$cost_human$cost), 1)                    # "the average site still costs 1"
  expect_equal(round(range(s4$cost_human$cost), 2), c(0.22, 2.26))   # "from 0.22 to 2.26"
  expect_equal(s4$budget_human, 20.2)                          # "the same budget of 20.2"
  expect_equal(s4$budget_human, s4$budget_frac * nrow(s4$cost_equal))
  expect_equal(sum(s4$plan_cost$selected), 32)                 # "32 instead of 20"
  expect_equal(round(ch(s4$plan_cost), 1), 20.2)               # "`spent` ... 20.2 for Plan 3"
  keep <- s4$plan_redlist$Site[s4$plan_redlist$selected]
  expect_true(all(keep %in% s4$plan_cost$Site[s4$plan_cost$selected]))  # "keeps all 20 of Plan 2's sites"
  expect_equal(round(ch(s4$plan_redlist), 1), 13.8)            # "Plan 2's 20 sites cost only 13.8"
  expect_equal(met(s4$plan_cost, s4$threatened), 11)           # "11 threatened species meet their target"
})

test_that("Plan 4: 9 domestic species out, 99 left in, 7 sites change", {
  expect_equal(sum(s4$status$local_status == "dom"), 9)        # "Nine species ... are domestic"
  expect_equal(sum(s4$w_wild$weight > 0), 99)
  changed <- sum(s4$plan_wild$selected != s4$plan_cost$selected[match(s4$plan_wild$Site, s4$plan_cost$Site)])
  expect_equal(changed, 7)
})

test_that("51 of 101 sites are in the reserve, and every plan puts two in three to three in four of its sites there", {
  inside <- s4$sites$Site[s4$sites$streamOrigin == "insideGLGS"]
  expect_equal(length(inside), 51)
  for (plan in list(s4$plan_equal, s4$plan_redlist, s4$plan_cost, s4$plan_wild)) {
    share <- mean(plan$Site[plan$selected] %in% inside)
    expect_gte(share, 0.6)
    expect_lte(share, 0.75)
  }
})

test_that("the toy plan picks sites 1 and 3, not the two richest", {
  expect_equal(which(s4$toy_solution$solution_1 == 1), c(1, 3))   # "picks sites 1 and 3 instead"
  expect_gte(0.9 / 1.7, 0.5)                                      # "meets their 50% targets"
})
