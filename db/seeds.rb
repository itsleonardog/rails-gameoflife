puts 'Reset database'
Cell.destroy_all

puts 'Seed database'
13.times do |row|
  13.times do |col|
    Cell.create(row: row, column: col, alive: false)
  end
end

puts 'Creazione pattern'
live_cells = [
  [1, 1], [1, 2], [1, 3], [1, 9], [1, 10], [1, 11],
  [3, 1], [3, 5], [3, 6], [3, 7], [3, 9], [3, 11],
  [5, 1], [5, 2], [5, 3], [5, 9], [5, 10], [5, 11],
  [7, 1], [7, 5], [7, 11],
  [9, 1], [9, 3], [9, 4], [9, 5], [9, 7], [9, 8], [9, 9], [9, 11]
]

puts 'Iterazione attraverso le coppie di coordinate e creazione di celle vive'
live_cells.each do |coordinates|
  row, column = coordinates
  Cell.find_by(row: row, column: column).update(alive: true)
end

puts 'Seed completato'
