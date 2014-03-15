require 'csv'

csv_text = File.read('profil.csv')
csv = CSV.parse(csv_text, :headers => false)
csv.each do |row|
	# puts "Current row: #{row}"
	if User.find_by(email: row[1]).nil? and !row[4].to_s.empty? and !row[5].to_s.empty?
		User.create!(first_name: row[4], last_name: row[5], email: row[1], password: row[3], password_confirmation: row[3])
		# puts "Iserting user: #{row} " 
	end
end