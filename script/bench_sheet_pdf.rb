require 'benchmark'
require 'mork'

def build_content(pages:, unequal:)
  Array.new(pages) do |i|
    choices =
      if unequal
        Array.new(120) { |j| 1 + ((i + j) % 5) }
      else
        [5] * 120
      end

    {
      barcode: i,
      choices: choices,
      header: { title: "Test #{i + 1}" }
    }
  end
end

def measure(label)
  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  result = yield
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at
  [label, elapsed, result]
end

puts "ruby=#{RUBY_VERSION} prawn=#{Prawn::VERSION}"
puts "pages\tshape\tbuild_s\trender_s\tbytes"

[1, 20, 100].each do |pages|
  [[false, 'equal'], [true, 'unequal']].each do |unequal, shape|
    content = build_content(pages: pages, unequal: unequal)

    _, build_s, pdf = measure('build') { Mork::SheetPDF.new(content) }
    _, render_s, bytes = measure('render') { pdf.to_pdf.bytesize }

    puts [pages, shape, format('%.6f', build_s), format('%.6f', render_s), bytes].join("\t")
  end
end
