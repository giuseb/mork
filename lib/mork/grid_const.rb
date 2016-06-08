module Mork
  # this is the default grid!
  # default units are millimiters
  DGRID = {
    # size of the paper sheet
    page_size: {
      # this is A4
      width:      210,
      height:     297
    },
    # size, location, search parameters of registration marks
    reg_marks: {
      margin:      10,
      radius:       3,
      offset:       2, # distance between page edge and registraton mark search area
      crop:        20, # size of square where the regmark should be located
      dilate:       5, # set to >0 to apply a dilate IM operation
      blur:         2, # set to >0 to apply a blur IM operation
      contrast:    20  # minimum contrast between registration mark circles and the white paper
    },
    header: {
      name: {
        top:        5,
        left:      15,
        width:    160,
        height:     7,
        size:      14
      },
      title: {
        top:       15,
        left:      15,
        width:    160,
        height:    12,
        size:      12
      },
      code: {
        top:        35,
        left:      130,
        width:      57,
        height:     10,
        size:       14,
        align:   :right
      },
      signature: {
        top:        30,
        left:       15,
        width:     120,
        height:     15,
        size:        7,
        box:      true
      }
    }, # header end
    items: {
      threshold:     0.75,
      columns:       4,
      column_width: 44,
      rows:         30,
      # from the top-left registration mark
      # to the center of the first choice cell
      left:         11,
      top:          55,
      # between choices
      x_spacing:     7,
      # between rows
      y_spacing:     7,
      # darkened area
      cell_width:    6,
      cell_height:   5,
      # the maximum number of choices per question
      max_cells:     5,
      # font size for the question number and choice letters
      font_size:     9,
      # distance between right side of q num and left side of first choice cell
      number_width:  8,
      # width of question number text box
      number_margin: 2
    }, # items end
    barcode: {
      bits:         40,
      left:         15,
      width:         3,
      height:        3,
      spacing:       4
    } # barcode end
  }
end
