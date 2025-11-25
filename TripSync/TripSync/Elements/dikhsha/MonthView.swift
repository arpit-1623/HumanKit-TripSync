//
//  MonthView.swift
//  TripSync
//
//  Created on 25/11/2025.
//

import UIKit

class MonthView: UIView {
    
    // MARK: - Properties
    private let monthLabel = UILabel()
    private let weekdayStackView = UIStackView()
    private let daysContainerStackView = UIStackView()
    
    private var dateToButtonMap: [Date: UIButton] = [:]
    private var year: Int = 0
    private var month: Int = 0
    
    var onDayTapped: ((Date) -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        // Month label
        monthLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        monthLabel.textColor = .label
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(monthLabel)
        
        // Weekday header
        weekdayStackView.axis = .horizontal
        weekdayStackView.distribution = .fillEqually
        weekdayStackView.spacing = 0
        weekdayStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(weekdayStackView)
        
        let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
        for day in weekdays {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            label.textColor = UIColor(white: 0.6, alpha: 1.0)
            weekdayStackView.addArrangedSubview(label)
        }
        
        // Days container
        daysContainerStackView.axis = .vertical
        daysContainerStackView.distribution = .fillEqually
        daysContainerStackView.spacing = 8
        daysContainerStackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(daysContainerStackView)
        
        // Constraints
        NSLayoutConstraint.activate([
            monthLabel.topAnchor.constraint(equalTo: topAnchor),
            monthLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            monthLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            weekdayStackView.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 16),
            weekdayStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            weekdayStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30),
            
            daysContainerStackView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 8),
            daysContainerStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            daysContainerStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            daysContainerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Configuration
    func configure(year: Int, month: Int, selectedStart: Date?, selectedEnd: Date?) {
        self.year = year
        self.month = month
        
        // Set month label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        if let date = Calendar.current.date(from: DateComponents(year: year, month: month)) {
            monthLabel.text = dateFormatter.string(from: date)
        }
        
        // Clear existing days
        daysContainerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        dateToButtonMap.removeAll()
        
        // Generate calendar grid
        generateDaysGrid()
        
        // Update appearances
        if let start = selectedStart, let end = selectedEnd {
            highlightRange(start: start, end: end)
        } else if let start = selectedStart {
            updateButtonAppearance(for: start, isStart: true, isEnd: false, isInRange: false)
        }
    }
    
    private func generateDaysGrid() {
        let calendar = Calendar.current
        
        // Get first day of month
        guard let firstDayOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)) else {
            return
        }
        
        // Get weekday of first day (1 = Sunday, 7 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth) - 1
        
        // Get number of days in month
        guard let range = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else {
            return
        }
        let numberOfDays = range.count
        
        // Calculate total cells needed
        let totalCells = firstWeekday + numberOfDays
        let numberOfRows = Int(ceil(Double(totalCells) / 7.0))
        
        // Create rows
        var dayCounter = 1
        
        for row in 0..<numberOfRows {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 8
            
            for column in 0..<7 {
                let cellIndex = row * 7 + column
                
                if cellIndex < firstWeekday || dayCounter > numberOfDays {
                    // Empty cell
                    let emptyView = UIView()
                    rowStackView.addArrangedSubview(emptyView)
                } else {
                    // Day button
                    let button = createDayButton(day: dayCounter)
                    rowStackView.addArrangedSubview(button)
                    
                    // Store in map
                    if let date = calendar.date(from: DateComponents(year: year, month: month, day: dayCounter)) {
                        dateToButtonMap[normalizeDate(date)] = button
                    }
                    
                    dayCounter += 1
                }
            }
            
            daysContainerStackView.addArrangedSubview(rowStackView)
        }
    }
    
    private func createDayButton(day: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("\(day)", for: .normal)
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        button.backgroundColor = .clear
        button.tag = day
        button.addTarget(self, action: #selector(dayButtonTapped(_:)), for: .touchUpInside)
        
        // Ensure square aspect ratio
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalTo: button.widthAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        return button
    }
    
    @objc private func dayButtonTapped(_ sender: UIButton) {
        let day = sender.tag
        let calendar = Calendar.current
        
        if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) {
            onDayTapped?(normalizeDate(date))
        }
    }
    
    // MARK: - Selection Management
    func clearSelections() {
        for (_, button) in dateToButtonMap {
            button.backgroundColor = .clear
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 0
        }
    }
    
    func highlightRange(start: Date, end: Date) {
        let normalizedStart = normalizeDate(start)
        let normalizedEnd = normalizeDate(end)
        let calendar = Calendar.current
        
        for (date, button) in dateToButtonMap {
            let isStart = calendar.isDate(date, inSameDayAs: normalizedStart)
            let isEnd = calendar.isDate(date, inSameDayAs: normalizedEnd)
            let isInRange = date > normalizedStart && date < normalizedEnd
            
            updateButtonAppearance(button: button, isStart: isStart, isEnd: isEnd, isInRange: isInRange)
        }
    }
    
    private func updateButtonAppearance(for date: Date, isStart: Bool, isEnd: Bool, isInRange: Bool) {
        let normalizedDate = normalizeDate(date)
        if let button = dateToButtonMap[normalizedDate] {
            updateButtonAppearance(button: button, isStart: isStart, isEnd: isEnd, isInRange: isInRange)
        }
    }
    
    private func updateButtonAppearance(button: UIButton, isStart: Bool, isEnd: Bool, isInRange: Bool) {
        if isStart || isEnd {
            // Orange circle for start/end dates
            button.backgroundColor = .systemOrange
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 22
        } else if isInRange {
            // Light gray rounded rectangle for in-range dates
            button.backgroundColor = UIColor.systemGray5
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 8
        } else {
            // Default appearance
            button.backgroundColor = .clear
            button.setTitleColor(.label, for: .normal)
            button.layer.cornerRadius = 0
        }
    }
    
    // MARK: - Helper Methods
    private func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
}
