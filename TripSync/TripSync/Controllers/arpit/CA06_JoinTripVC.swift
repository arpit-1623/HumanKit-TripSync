//
//  JoinTripViewController.swift
//  TripSync
//
//  Created by Arpit Garg on 21/11/25.
//

import UIKit
import AVFoundation

class JoinTripViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var scanContainerView: UIView!
    @IBOutlet weak var cameraPreviewView: UIView!
    @IBOutlet weak var viewfinderOverlay: UIView!
    @IBOutlet weak var codeContainerView: UIView!
    @IBOutlet weak var inviteCodeTextField: UITextField!
    
    // MARK: - Properties
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTextField()
        drawViewfinderFrame()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if segmentedControl.selectedSegmentIndex == 0 {
            checkCameraPermissionsAndSetup()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopScanning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraPreviewView.bounds
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Initially show scan container
        scanContainerView.isHidden = false
        codeContainerView.isHidden = true
    }
    
    private func setupTextField() {
        inviteCodeTextField.delegate = self
        inviteCodeTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    private func drawViewfinderFrame() {
        // Draw corner brackets for viewfinder
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = UIColor.systemBlue.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        let path = UIBezierPath()
        let cornerLength: CGFloat = 30
        let bounds = viewfinderOverlay.bounds
        
        // Top-left corner
        path.move(to: CGPoint(x: 0, y: cornerLength))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: cornerLength, y: 0))
        
        // Top-right corner
        path.move(to: CGPoint(x: bounds.width - cornerLength, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: cornerLength))
        
        // Bottom-right corner
        path.move(to: CGPoint(x: bounds.width, y: bounds.height - cornerLength))
        path.addLine(to: CGPoint(x: bounds.width, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width - cornerLength, y: bounds.height))
        
        // Bottom-left corner
        path.move(to: CGPoint(x: cornerLength, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.height))
        path.addLine(to: CGPoint(x: 0, y: bounds.height - cornerLength))
        
        shapeLayer.path = path.cgPath
        viewfinderOverlay.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Camera Setup
    private func checkCameraPermissionsAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async {
                        self?.setupScanner()
                    }
                }
            }
        case .denied, .restricted:
            showCameraPermissionAlert()
        @unknown default:
            break
        }
    }
    
    private func setupScanner() {
        captureSession = AVCaptureSession()
        
        guard let captureSession = captureSession,
              let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                return
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if captureSession.canAddOutput(metadataOutput) {
                captureSession.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.qr]
            } else {
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer?.frame = cameraPreviewView.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            
            if let previewLayer = previewLayer {
                cameraPreviewView.layer.addSublayer(previewLayer)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                captureSession.startRunning()
            }
        } catch {
            print("Error setting up camera: \(error.localizedDescription)")
        }
    }
    
    private func stopScanning() {
        captureSession?.stopRunning()
    }
    
    private func showCameraPermissionAlert() {
        let alert = UIAlertController(
            title: "Camera Access Required",
            message: "Please enable camera access in Settings to scan QR codes.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - Actions
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: // Scan QR Code
            scanContainerView.isHidden = false
            codeContainerView.isHidden = true
            inviteCodeTextField.resignFirstResponder()
            checkCameraPermissionsAndSetup()
        case 1: // Enter Code
            scanContainerView.isHidden = true
            codeContainerView.isHidden = false
            stopScanning()
            inviteCodeTextField.becomeFirstResponder()
        default:
            break
        }
    }
    
    @IBAction func closeTapped(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func joinTripTapped(_ sender: UIButton) {
        let code: String
        
        if segmentedControl.selectedSegmentIndex == 0 {
            // Scanning mode - would be set when QR is detected
            showAlert(title: "Scan QR Code", message: "Please scan a valid trip QR code.")
            return
        } else {
            // Manual entry mode
            guard let enteredCode = inviteCodeTextField.text?.uppercased(),
                  !enteredCode.isEmpty else {
                showAlert(title: "Enter Code", message: "Please enter a trip code.")
                return
            }
            code = enteredCode
        }
        
        // Validate and join trip
        validateAndJoinTrip(with: code)
    }
    
    @objc private func textFieldDidChange() {
        // Auto-uppercase and format
        if let text = inviteCodeTextField.text {
            inviteCodeTextField.text = text.uppercased()
        }
    }
    
    // MARK: - Trip Join Logic
    private func validateAndJoinTrip(with code: String) {
        guard let currentUser = DataModel.shared.getCurrentUser() else {
            showAlert(title: "Error", message: "You must be logged in to join a trip.")
            return
        }
        
        do {
            // Attempt to join trip with the invite code
            let joinedTrip = try DataModel.shared.joinTripWithCode(currentUser.id, inviteCode: code)
            
            // Success - navigate to trip details
            showSuccessAndNavigate(to: joinedTrip)
            
        } catch JoinTripError.invalidCode {
            showAlert(title: "Invalid Code", message: "No trip found with this invite code. Please check and try again.")
        } catch JoinTripError.alreadyMember {
            showAlert(title: "Already Joined", message: "You're already a member of this trip.")
        } catch {
            showAlert(title: "Error", message: "An unexpected error occurred: \(error.localizedDescription)")
        }
    }
    
    private func showSuccessAndNavigate(to trip: Trip) {
        // Get the presenting tab bar and navigation controller BEFORE dismissing
        guard let presentingTabBar = presentingViewController as? UITabBarController,
              let selectedNav = presentingTabBar.selectedViewController as? UINavigationController else {
            dismiss(animated: true)
            return
        }
        
        // Load trip details from storyboard
        let storyboard = UIStoryboard(name: "SA02_TripDetails", bundle: nil)
        guard let tripDetailsVC = storyboard.instantiateViewController(withIdentifier: "TripDetailsViewController") as? TripDetailsViewController else {
            dismiss(animated: true)
            return
        }
        
        tripDetailsVC.trip = trip
        
        // Dismiss the modal and navigate to trip details
        dismiss(animated: true) {
            selectedNav.pushViewController(tripDetailsVC, animated: true)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension JoinTripViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        // Stop scanning and vibrate
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        stopScanning()
        
        // Join trip with scanned code
        validateAndJoinTrip(with: stringValue)
    }
}

// MARK: - UITextFieldDelegate
extension JoinTripViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Limit to 12 characters (allowing for some flexibility)
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 12
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        joinTripTapped(UIButton()) // Trigger join action
        return true
    }
}
