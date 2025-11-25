//
//  CD02_DatePickerVC.swift
//  TripSync
//
//  Created on 25/11/2025.
//

import UIKit

// MARK: - Delegate Protocol
protocol DateRangePickerDelegate: AnyObject {
    func didSelectDateRange(start: Date, end: Date)
}

class CD02_DatePickerVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var monthsStackView: UIStackView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    // MARK: - Properties
    weak var delegate: DateRangePickerDelegate?
    
    private var startDate: Date?
    private var endDate: Date?
    
    private var monthViews: [MonthView] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        generateMonthViews()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Configure confirm button
        confirmButton.setTitleColor(.systemOrange, for: .normal)
        confirmButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        
        // Configure cancel button
        cancelButton.setTitleColor(.systemOrange, for: .normal)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
    }
    
    private func generateMonthViews() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        // Generate 12 months: current month + 11 forward
        for monthOffset in 0..<12 {
            guard let targetDate = calendar.date(byAdding: .month, value: monthOffset, to: currentDate) else {
                continue
            }
            
            let year = calendar.component(.year, from: targetDate)
            let month = calendar.component(.month, from: targetDate)
            
            let monthView = MonthView()
            monthView.configure(year: year, month: month, selectedStart: startDate, selectedEnd: endDate)
            monthView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set tap handler
            monthView.onDayTapped = { [weak self] date in
                self?.handleDayTapped(date)
            }
            
            monthsStackView.addArrangedSubview(monthView)
            monthViews.append(monthView)
            
            // Add height constraint for proper layout
            monthView.heightAnchor.constraint(equalToConstant: 350).isActive = true
        }
    }
    
    // MARK: - Date Selection Logic
    private func handleDayTapped(_ date: Date) {
        if startDate == nil {
            // First selection - set start date
            startDate = date
            endDate = nil
            updateAllMonthViews()
        } else if endDate == nil {
            // Second selection - set end date
            endDate = date
            
            // Ensure start is before end (swap if needed)
            if let start = startDate, let end = endDate, end < start {
                swap(&startDate, &endDate)
            }
            
            updateAllMonthViews()
        } else {
            // Third selection - reset and start over
            startDate = date
            endDate = nil
            updateAllMonthViews()
        }
    }
    
    private func updateAllMonthViews() {
        for monthView in monthViews {
            monthView.clearSelections()
            
            if let start = startDate, let end = endDate {
                monthView.highlightRange(start: start, end: end)
            } else if let start = startDate {
                monthView.highlightRange(start: start, end: start)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func confirmButtonTapped(_ sender: UIButton) {
        guard let start = startDate, let end = endDate else {
            // Show alert if dates not selected
            let alert = UIAlertController(
                title: "Select Dates",
                message: "Please select both start and end dates.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        delegate?.didSelectDateRange(start: start, end: end)
        dismiss(animated: true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
