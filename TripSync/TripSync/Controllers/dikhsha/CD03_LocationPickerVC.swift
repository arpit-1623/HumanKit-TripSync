//
//  CD03_LocationPickerVC.swift
//  TripSync
//
//  Created on 25/11/2025.
//

import UIKit
import MapKit

// MARK: - Delegate Protocol
protocol LocationPickerDelegate: AnyObject {
    func locationPicker(_ picker: CD03_LocationPickerVC, didSelectLocationDisplayName: String)
}

class CD03_LocationPickerVC: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultsTableView: UITableView!
    
    // MARK: - Properties
    weak var delegate: LocationPickerDelegate?
    
    private let searchCompleter = MKLocalSearchCompleter()
    private var completions: [MKLocalSearchCompletion] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupSearchCompleter()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchTextField.becomeFirstResponder()
    }
    
    // MARK: - Setup
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        // Configure search text field
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    private func setupSearchCompleter() {
        searchCompleter.delegate = self
        searchCompleter.resultTypes = [.address, .pointOfInterest]
    }
    
    private func setupTableView() {
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        resultsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "LocationCell")
    }
    
    // MARK: - Text Field Handling
    @objc private func textDidChange(_ textField: UITextField) {
        searchCompleter.queryFragment = textField.text ?? ""
    }
    
    // MARK: - Actions
    @IBAction func didTapCancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CD03_LocationPickerVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - MKLocalSearchCompleterDelegate
extension CD03_LocationPickerVC: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        completions = completer.results
        resultsTableView.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Location search error: \(error.localizedDescription)")
    }
}

// MARK: - UITableViewDataSource
extension CD03_LocationPickerVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        let result = completions[indexPath.row]
        
        // Configure cell text
        cell.textLabel?.text = result.title
        cell.textLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        cell.textLabel?.textColor = .label
        
        cell.detailTextLabel?.text = result.subtitle
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        // Add location icon
        cell.imageView?.image = UIImage(systemName: "mappin.circle.fill")
        cell.imageView?.tintColor = .systemRed
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CD03_LocationPickerVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let result = completions[indexPath.row]
        let name = result.title
        let country = result.subtitle
        
        let formatted = country.isEmpty ? name : "\(name)"
        
        delegate?.locationPicker(self, didSelectLocationDisplayName: formatted)
        dismiss(animated: true)
    }
}
