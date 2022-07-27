my_kable <- function(dat, caption_text = '', font = font_set){
  dat %>%
    kable(caption = caption_text, booktabs = T) %>%
    kableExtra::kable_styling(c("condensed", "responsive"),
                              full_width = T,
                              font_size = font)
  # kableExtra::scroll_box(width = "100%", height = "500px")
}

##function to trim up sheet and get names (was previously source from altools package)
at_trim_xlsheet2 <- function(df, column_last = ncol(df)) {
  df %>%
    dplyr::select(1:column_last) %>% ##get rid of the extra columns.  should be more abstract
    janitor::row_to_names(which.max(complete.cases(.))) %>%
    janitor::clean_names() %>%
    janitor::remove_empty(., which = "rows")
}

##function to import pscis info
import_pscis <- function(workbook_name = 'pscis_phase1.xlsm'){ ##new template.  could change file back to .xls
  sig_fig0 <- c('length_or_width_meters')
  sig_fig1 <- c('culvert_slope_percent', 'stream_width_ratio')
  sig_fig2 <- c('outlet_drop_meters')
  readxl::read_excel(path = paste0(getwd(),"/data/", workbook_name),
                     sheet = 'PSCIS Assessment Worksheet') %>%
    # purrr::set_names(janitor::make_clean_names(names(.))) %>%
    at_trim_xlsheet2() %>% ##recently added function above and pulled the altools package as it was a week link
    rename(date = date_of_assessment_yyyy_mm_dd) %>%
    mutate(date = janitor::excel_numeric_to_date(as.numeric(date))) %>%
    filter(!is.na(date)) %>%
    readr::type_convert() %>%  ##guess the type!!
    mutate(source = workbook_name) %>%
    mutate(across(all_of(sig_fig0), round, 0)) %>%
    mutate(across(all_of(sig_fig1), round, 1)) %>%
    mutate(across(all_of(sig_fig2), round, 2))
}

## add a line to the function to make the comments column wide enough
make_html_tbl <- function(df) {
  # df2 <- df %>%
  #   dplyr::mutate(`Image link` = cell_spec('crossing', "html", link = `Image link`))
  df2 <- select(df, -blue_line_key, -linear_feature_id, -lat, -long,
                -sub5, -name, -desc, -shape, -watershed_code_20k, watershed_code_50k,-color) %>%
    sf::st_drop_geometry() %>%
    janitor::remove_empty() #, -shape, -color, -label
  df %>%
    mutate(html_tbl = knitr::kable(df2, 'html', escape = F) %>%
             kableExtra::row_spec(0:nrow(df2), extra_css = "border: 1px solid black;") %>% # All cells get a border
             kableExtra::row_spec(0, background = "yellow") %>%
             kableExtra::column_spec(column = ncol(df2) - 1, width_min = '0.5in') %>%
             kableExtra::column_spec(column = ncol(df2), width_min = '4in')
    )
}


test_fpr_kable <- function(dat,
                      caption_text = '',
                      font = font_set,
                      footnote_text = NULL,
                      scroll = TRUE,
                      scroll_box_height = "500px",
                      col_width_max = NULL,
                      width_max = '1.0in'){
  dat2 <- dat %>%
    knitr::kable(caption = caption_text, booktabs = T) %>%
    kableExtra::kable_styling(c("condensed", "responsive"),
                              full_width = T,
                              font_size = font)
  if(!is.null(footnote_text)){
    dat2 <- dat2 %>%
      kableExtra::footnote(symbol = footnote_text)
  }
  if(!is.null(col_width_max)){
    dat2 <- dat2 %>%
      kableExtra::column_spec(column = col_width_max, width_min = width_max)
  }
  if(identical(scroll,TRUE)){
    dat2 <- dat2 %>%
      kableExtra::scroll_box(width = "100%", height = scroll_box_height)
  }

  dat2
}
