module Mork
  class Grid
    # @private
    # this is the default grid!
    # default units are millimiters
    def default_grid
      {
        # size of the paper sheet
        page_size: {
          width:      210, # A4
          height:     297
        },
        # size, location, search parameters of registration marks
        reg_marks: {
          margin:      10, # from sheet edge to registration mark center
          radius:       3, # of the registration circle
          offset:       2, # distance between page edge and registraton mark search area
          crop:        20, # size of square where the regmark should be located
          dilate:       5, # set to >0 to apply a dilate IM operation
          blur:         2, # set to >0 to apply a blur IM operation
          contrast:    20  # minimum contrast between registration mark circles and the white paper
        },
        # you can place multiple elements in the header; title is the only default
        header: {
          title: {
            top:       15,
            left:      15,
            width:    160,
            height:    12,
            size:      12,
            box:    false
          }
        },
        # questions and answers
        items: {
          threshold:     0.75, # how much darker a marked cell should be compared to cal cells
          columns:       4,
          column_width: 44,
          rows:         30,
          left:         11, # distance from the top-left registration mark...
          top:          55, # ...to the center of the first choice cell
          x_spacing:     7, # between choices
          y_spacing:     7, # between rows
          cell_width:    6, # choice cell size
          cell_height:   5, # choice cell size
          max_cells:     5, # the maximum number of choices per question
          font_size:     9, # for the question number and choice letters
          number_width:  8, # width of question number text box
          number_margin: 2  # distance between right side of q num and left side of first choice cell
        },
        # unique sheet ID as a binary barcode
        barcode: {
          bits:         38,
          left:         15,
          width:         3,
          height:        3,
          spacing:       4
        }
      }
    end
  end
end
