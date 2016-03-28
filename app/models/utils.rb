require 'csv'
require 'set'

class Utils
  def self.alpha_sort(list, field)
    return list.sort_by!{|x|
      x[field].gsub(/\d+/){|m| "0"*(6-m.size)+m}
    }
  end

  def self.split_by_colon(course)
    index = course.index(":")
    number = course[0..(index-1)]
    title = course[(index + 2)..(course.length - 1)]
    return title, number
  end

  def self.parseData()
    all = []
    CSV.foreach('prof_data_min.csv', converters: :numeric) do |row|
      name = row[1] + " " + row[0]
      course = row[2].split(' ', 2)[0]
      term = row[2].split(' ', 2)[1]
      question = row[3]
      total = row[4] + row[5] + row[6] + row[7] + row[8] + row[9] + row[10]
      avg = (row[4]*1 + row[5]*2 + row[6]*3 + row[7]*4 + row[8]*5 + row[9]*6 + row[10]*7).to_f
      avg = (avg/total).round(2)
      entry = all.find { |hash| hash[:name] == name and hash[:course] == course}
      if entry
        entry[:questions][question] = avg
      else
        hash = {:name => name, :course => course, :questions => {}}
        hash[:questions][question] = avg
        all << hash
      end
    end
    puts all
  end

  def self.seedDatabase()
    Professor.destroy_all
    ProfessorCourse.destroy_all
    Course.destroy_all

    CSV.foreach('newFile.csv', converters: :numeric) do |row|
      name = row[1] + " " + row[0] # John Denero
      number = row[2].split(' ', 2)[0] # CS61A
      term = row[2].split(' ', 2)[1] # Fall 2015
      title = row[3] # Structure and Interpretation ...
      total = row[4] + row[5] + row[6] + row[7] + row[8] + row[9] + row[10]
      avg = (row[4]*1 + row[5]*2 + row[6]*3 + row[7]*4 + row[8]*5 + row[9]*6 + row[10]*7).to_f
      rating = (avg/total).round(2) # Rating

      if Professor.find_by(name: name) == nil
        professor = Professor.create(name: name)
      else
        professor = Professor.find_by(name: name)
      end
      Course.create(number: number)
      professor.courses.create(number: number, rating: rating, term: term, title: title)
    end
  end

  def self.newDataFile()
    begin
      file = File.open("newFile.csv", "w")
      IO.readlines('prof_data.csv').each do |line|
        puts line
        if line =~ /Rate the overall teaching/
          file.write(line)
        end
      end
    rescue IOError => e
      puts "lol"
    ensure
      file.close unless file.nil?
    end
  end

  def self.uniqueCourses()
    file = File.open("newFile2.csv", "w")
    all_numbers = Set.new
    CSV.foreach('newFile.csv', converters: :numeric) do |line|
      puts line
      number = line[2].split(' ', 2)[0]
      if not all_numbers.include?(number)
        file.write(number + "," + "\n")
        all_numbers.add(number)
      end
    end
  rescue IOError => e
    puts "lol"
  ensure
    file.close unless file.nil?
  end
end
