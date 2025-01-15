sequencing_id_suffix <- "ABCDEF001_ss.A0101.TF1.1"
capture_id_suffix    <- "ABCDEF001_ss.A0101.TF1"
library_id_suffix    <- "ABCDEF001_ss.A0101"
extract_id_suffix    <- "ABCDEF001_ss.A01"
sample_id_suffix     <- "ABCDEF001_ss.A"
individual_id_suffix <- "ABCDEF001_ss"
site_id_suffix       <- "ABCDEF"

sequencing_id        <- "ABCDEF001.A0101.TF1.1"
capture_id           <- "ABCDEF001.A0101.TF1"
library_id           <- "ABCDEF001.A0101"
extract_id           <- "ABCDEF001.A01"
sample_id            <- "ABCDEF001.A"
individual_id        <- "ABCDEF001"
site_id              <- "ABCDEF"

test_that("Site_ID correctly inferred (no suffix)"        , {
  expect_equal(get_site_id(sequencing_id_suffix           , keep_ss_suffix = F), site_id )
  expect_equal(get_site_id(capture_id_suffix              , keep_ss_suffix = F), site_id )
  expect_equal(get_site_id(library_id_suffix              , keep_ss_suffix = F), site_id )
  expect_equal(get_site_id(extract_id_suffix              , keep_ss_suffix = F), site_id )
  expect_equal(get_site_id(sample_id_suffix               , keep_ss_suffix = F), site_id )
  expect_equal(get_site_id(individual_id_suffix           , keep_ss_suffix = F), site_id )
  expect_equal(get_site_id(site_id_suffix                 , keep_ss_suffix = F), site_id )
})

test_that("Site_ID correctly inferred (keep suffix)"      , {
  expect_equal(get_site_id(sequencing_id_suffix           , keep_ss_suffix = T), site_id_suffix )
  expect_equal(get_site_id(capture_id_suffix              , keep_ss_suffix = T), site_id_suffix )
  expect_equal(get_site_id(library_id_suffix              , keep_ss_suffix = T), site_id_suffix )
  expect_equal(get_site_id(extract_id_suffix              , keep_ss_suffix = T), site_id_suffix )
  expect_equal(get_site_id(sample_id_suffix               , keep_ss_suffix = T), site_id_suffix )
  expect_equal(get_site_id(individual_id_suffix           , keep_ss_suffix = T), site_id_suffix )
  expect_equal(get_site_id(site_id_suffix                 , keep_ss_suffix = T), site_id_suffix )
})

test_that("Individual_ID correctly inferred (no suffix)"  , {
  ## Expected warnings
  expect_warning(site_out <- get_ind_id(site_id_suffix    , keep_ss_suffix = F))

  expect_equal(get_ind_id(sequencing_id_suffix            , keep_ss_suffix = F), individual_id)
  expect_equal(get_ind_id(capture_id_suffix               , keep_ss_suffix = F), individual_id)
  expect_equal(get_ind_id(library_id_suffix               , keep_ss_suffix = F), individual_id)
  expect_equal(get_ind_id(extract_id_suffix               , keep_ss_suffix = F), individual_id)
  expect_equal(get_ind_id(sample_id_suffix                , keep_ss_suffix = F), individual_id)
  expect_equal(get_ind_id(individual_id_suffix            , keep_ss_suffix = F), individual_id)
  expect_equal(site_out                                                        , NA_character_)
})

test_that("Individual_ID correctly inferred (keep suffix)", {
  ## Expected warnings
  expect_warning(site_out <- get_ind_id(site_id_suffix    , keep_ss_suffix = T))

  expect_equal(get_ind_id(sequencing_id_suffix            , keep_ss_suffix = T), individual_id_suffix)
  expect_equal(get_ind_id(capture_id_suffix               , keep_ss_suffix = T), individual_id_suffix)
  expect_equal(get_ind_id(library_id_suffix               , keep_ss_suffix = T), individual_id_suffix)
  expect_equal(get_ind_id(extract_id_suffix               , keep_ss_suffix = T), individual_id_suffix)
  expect_equal(get_ind_id(sample_id_suffix                , keep_ss_suffix = T), individual_id_suffix)
  expect_equal(get_ind_id(individual_id_suffix            , keep_ss_suffix = T), individual_id_suffix)
  expect_equal(site_out                                                        , NA_character_)
})

test_that("Sample_ID correctly inferred (no suffix)"      , {
  ## Expected warnings
  expect_warning(ind_out  <- get_sample_id(individual_id_suffix , keep_ss_suffix = F))
  expect_warning(site_out <- get_sample_id(site_id_suffix       , keep_ss_suffix = F))

  expect_equal(get_sample_id(sequencing_id_suffix         , keep_ss_suffix = F), sample_id)
  expect_equal(get_sample_id(capture_id_suffix            , keep_ss_suffix = F), sample_id)
  expect_equal(get_sample_id(library_id_suffix            , keep_ss_suffix = F), sample_id)
  expect_equal(get_sample_id(extract_id_suffix            , keep_ss_suffix = F), sample_id)
  expect_equal(get_sample_id(sample_id_suffix             , keep_ss_suffix = F), sample_id)
  expect_equal(ind_out                                                         , NA_character_)
  expect_equal(site_out                                                        , NA_character_)
})

test_that("Sample_ID correctly inferred (keep suffix)"    , {
  ## Expected warnings
  expect_warning(ind_out  <- get_sample_id(individual_id_suffix , keep_ss_suffix = T))
  expect_warning(site_out <- get_sample_id(site_id_suffix       , keep_ss_suffix = T))

  expect_equal(get_sample_id(sequencing_id_suffix         , keep_ss_suffix = T), sample_id_suffix)
  expect_equal(get_sample_id(capture_id_suffix            , keep_ss_suffix = T), sample_id_suffix)
  expect_equal(get_sample_id(library_id_suffix            , keep_ss_suffix = T), sample_id_suffix)
  expect_equal(get_sample_id(extract_id_suffix            , keep_ss_suffix = T), sample_id_suffix)
  expect_equal(get_sample_id(sample_id_suffix             , keep_ss_suffix = T), sample_id_suffix)
  expect_equal(ind_out                                                         , NA_character_)
  expect_equal(site_out                                                        , NA_character_)
})


test_that("Extract_ID correctly inferred (no suffix)"     , {
  ## Expected warnings
  expect_warning(sam_out  <- get_extract_id(sample_id_suffix     , keep_ss_suffix = F))
  expect_warning(ind_out  <- get_extract_id(individual_id_suffix , keep_ss_suffix = F))
  expect_warning(site_out <- get_extract_id(site_id_suffix       , keep_ss_suffix = F))

  expect_equal(get_extract_id(sequencing_id_suffix      , keep_ss_suffix = F), extract_id)
  expect_equal(get_extract_id(capture_id_suffix         , keep_ss_suffix = F), extract_id)
  expect_equal(get_extract_id(library_id_suffix         , keep_ss_suffix = F), extract_id)
  expect_equal(get_extract_id(extract_id_suffix         , keep_ss_suffix = F), extract_id)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Extract_ID correctly inferred (keep suffix)"   , {
  ## Expected warnings
  expect_warning(sam_out  <- get_extract_id(sample_id_suffix     , keep_ss_suffix = T))
  expect_warning(ind_out  <- get_extract_id(individual_id_suffix , keep_ss_suffix = T))
  expect_warning(site_out <- get_extract_id(site_id_suffix       , keep_ss_suffix = T))

  expect_equal(get_extract_id(sequencing_id_suffix      , keep_ss_suffix = T), extract_id_suffix)
  expect_equal(get_extract_id(capture_id_suffix         , keep_ss_suffix = T), extract_id_suffix)
  expect_equal(get_extract_id(library_id_suffix         , keep_ss_suffix = T), extract_id_suffix)
  expect_equal(get_extract_id(extract_id_suffix         , keep_ss_suffix = T), extract_id_suffix)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Library_ID correctly inferred (no suffix)"     , {
  ## Expected warnings
  expect_warning(ext_out  <- get_library_id(extract_id_suffix    , keep_ss_suffix = F))
  expect_warning(sam_out  <- get_library_id(sample_id_suffix     , keep_ss_suffix = F))
  expect_warning(ind_out  <- get_library_id(individual_id_suffix , keep_ss_suffix = F))
  expect_warning(site_out <- get_library_id(site_id_suffix       , keep_ss_suffix = F))

  expect_equal(get_library_id(sequencing_id_suffix      , keep_ss_suffix = F), library_id)
  expect_equal(get_library_id(capture_id_suffix         , keep_ss_suffix = F), library_id)
  expect_equal(get_library_id(library_id_suffix         , keep_ss_suffix = F), library_id)
  expect_equal(ext_out                                                       , NA_character_)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Library_ID correctly inferred (keep suffix)"   , {
  ## Expected warnings
  expect_warning(ext_out  <- get_library_id(extract_id_suffix    , keep_ss_suffix = T))
  expect_warning(sam_out  <- get_library_id(sample_id_suffix     , keep_ss_suffix = T))
  expect_warning(ind_out  <- get_library_id(individual_id_suffix , keep_ss_suffix = T))
  expect_warning(site_out <- get_library_id(site_id_suffix       , keep_ss_suffix = T))

  expect_equal(get_library_id(sequencing_id_suffix      , keep_ss_suffix = T), library_id_suffix)
  expect_equal(get_library_id(capture_id_suffix         , keep_ss_suffix = T), library_id_suffix)
  expect_equal(get_library_id(library_id_suffix         , keep_ss_suffix = T), library_id_suffix)
  expect_equal(ext_out                                                       , NA_character_)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Capture_ID correctly inferred (no suffix)"     , {
  ## Expected warnings
  expect_warning(lib_out  <- get_capture_id(library_id_suffix    , keep_ss_suffix = F))
  expect_warning(ext_out  <- get_capture_id(extract_id_suffix    , keep_ss_suffix = F))
  expect_warning(sam_out  <- get_capture_id(sample_id_suffix     , keep_ss_suffix = F))
  expect_warning(ind_out  <- get_capture_id(individual_id_suffix , keep_ss_suffix = F))
  expect_warning(site_out <- get_capture_id(site_id_suffix       , keep_ss_suffix = F))

  expect_equal(get_capture_id(sequencing_id_suffix      , keep_ss_suffix = F), capture_id)
  expect_equal(get_capture_id(capture_id_suffix         , keep_ss_suffix = F), capture_id)
  expect_equal(lib_out                                                       , NA_character_)
  expect_equal(ext_out                                                       , NA_character_)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Capture_ID correctly inferred (keep suffix)"   , {
  ## Expected warnings
  expect_warning(lib_out  <- get_capture_id(library_id_suffix    , keep_ss_suffix = T))
  expect_warning(ext_out  <- get_capture_id(extract_id_suffix    , keep_ss_suffix = T))
  expect_warning(sam_out  <- get_capture_id(sample_id_suffix     , keep_ss_suffix = T))
  expect_warning(ind_out  <- get_capture_id(individual_id_suffix , keep_ss_suffix = T))
  expect_warning(site_out <- get_capture_id(site_id_suffix       , keep_ss_suffix = T))

  expect_equal(get_capture_id(sequencing_id_suffix      , keep_ss_suffix = T), capture_id_suffix)
  expect_equal(get_capture_id(capture_id_suffix         , keep_ss_suffix = T), capture_id_suffix)
  expect_equal(lib_out                                                       , NA_character_)
  expect_equal(ext_out                                                       , NA_character_)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Sequencing_ID correctly inferred (no suffix)"  , {
  ## Expected warnings
  expect_warning(cap_out  <- get_sequencing_id(capture_id_suffix    , keep_ss_suffix = F))
  expect_warning(lib_out  <- get_sequencing_id(library_id_suffix    , keep_ss_suffix = F))
  expect_warning(ext_out  <- get_sequencing_id(extract_id_suffix    , keep_ss_suffix = F))
  expect_warning(sam_out  <- get_sequencing_id(sample_id_suffix     , keep_ss_suffix = F))
  expect_warning(ind_out  <- get_sequencing_id(individual_id_suffix , keep_ss_suffix = F))
  expect_warning(site_out <- get_sequencing_id(site_id_suffix       , keep_ss_suffix = F))

  expect_equal(get_sequencing_id(sequencing_id_suffix   , keep_ss_suffix = F), sequencing_id)
  expect_equal(cap_out                                                       , NA_character_)
  expect_equal(lib_out                                                       , NA_character_)
  expect_equal(ext_out                                                       , NA_character_)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})

test_that("Sequencing_ID correctly inferred (keep suffix)", {
  ## Expected warnings
  expect_warning(cap_out  <- get_sequencing_id(capture_id_suffix    , keep_ss_suffix = T))
  expect_warning(lib_out  <- get_sequencing_id(library_id_suffix    , keep_ss_suffix = T))
  expect_warning(ext_out  <- get_sequencing_id(extract_id_suffix    , keep_ss_suffix = T))
  expect_warning(sam_out  <- get_sequencing_id(sample_id_suffix     , keep_ss_suffix = T))
  expect_warning(ind_out  <- get_sequencing_id(individual_id_suffix , keep_ss_suffix = T))
  expect_warning(site_out <- get_sequencing_id(site_id_suffix       , keep_ss_suffix = T))

  expect_equal(get_sequencing_id(sequencing_id_suffix   , keep_ss_suffix = T), sequencing_id_suffix)
  expect_equal(cap_out                                                       , NA_character_)
  expect_equal(lib_out                                                       , NA_character_)
  expect_equal(ext_out                                                       , NA_character_)
  expect_equal(sam_out                                                       , NA_character_)
  expect_equal(ind_out                                                       , NA_character_)
  expect_equal(site_out                                                      , NA_character_)
})
