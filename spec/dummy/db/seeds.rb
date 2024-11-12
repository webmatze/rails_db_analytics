# Clear existing data to ensure clean state
puts "Cleaning database..."
User.destroy_all
Team.destroy_all

puts "Creating teams and users..."

# Create teams with different sizes and characteristics
teams = [
  { name: "Engineering", created_at: rand(1..365).days.ago },
  { name: "Marketing", created_at: rand(1..365).days.ago },
  { name: "Sales", created_at: rand(1..365).days.ago },
  { name: "Product", created_at: rand(1..365).days.ago },
  { name: "Support", created_at: rand(1..365).days.ago }
]

teams.each do |team_attrs|
  Team.create!(team_attrs)
end

# Create users with varied attributes and team associations
50.times do |i|
  team_count = 1
  teams_to_assign = Team.all.sample(team_count)
  user = User.create!(
    username: "user#{i+1}",
    team: teams_to_assign.first,
    created_at: rand(1..365).days.ago
  )
end

puts "Seeding completed!"
puts "Created #{Team.count} teams"
puts "Created #{User.count} users"
