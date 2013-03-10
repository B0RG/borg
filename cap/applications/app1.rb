application :app1 do
  puts "application = app1"
end

stage :app1, :prd do
  puts "stage = prd"
end

stage :app1, :stg do
  puts "stage = stg"
end

stage :app1, :alf do
  puts "stage = alf"
end
