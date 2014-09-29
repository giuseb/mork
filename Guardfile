guard 'rspec', cmd: 'bundle exec rspec', all_after_pass: false do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/mork/(.+)\.rb$})     { |m| "spec/mork/#{m[1]}_spec.rb" }
end

# guard :shell do
#   watch "tmp/code_sample.pdf" do
#     system "open tmp/code_sample.pdf"
#   end
# end
