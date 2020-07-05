//
//  ViewController.swift
//  KapiTranslation
//
//  Created by Yebin Kim on 2020/02/26.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet var lanPicker: UIPickerView!
    @IBOutlet var originLanLabel: UILabel!
    @IBOutlet var originLanTextView: UITextView!
    @IBOutlet var transLanLabel: UILabel!
    @IBOutlet var transLanTextView: UITextView!
    @IBOutlet var transButton: UIButton!
    
    // MARK: - Properties
    
    let selectLanguage: [(lan: String, mark: String)] = [("한국어", "kr"),
                                                         ("영어", "en"),
                                                         ("일본어", "jp"),
                                                         ("중국어", "cn"),
                                                         ("베트남어", "vi"),
                                                         ("인도네시아어", "id"),
                                                         ("아랍어", "ar"),
                                                         ("뱅갈어", "bn"),
                                                         ("독일어", "de"),
                                                         ("스페인어", "es"),
                                                         ("프랑스어", "fr"),
                                                         ("힌디어", "hi"),
                                                         ("이탈리아어", "it"),
                                                         ("말레이시아어", "ms"),
                                                         ("네덜란드어", "nl"),
                                                         ("포르투갈어", "pt"),
                                                         ("러시아어", "ru"),
                                                         ("태국어", "th"),
                                                         ("터키어", "tr")]
    
    let queryService = QueryService()
    
    lazy var tapRecognizer: UITapGestureRecognizer = {
        var recognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        return recognizer
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setStyle()
        
        initializePickerView()
        initializeTextView()
        
        registerGestureRecognizer()
    }
    
    // MARK: - Layouts
    
    private func setStyle() {
        lanPicker.dropShadow()
        originLanLabel.dropShadow()
        originLanTextView.dropShadow()
        transLanLabel.dropShadow()
        transLanTextView.dropShadow()
        transButton.dropShadow()
    }
    
    // MARK: - Initializing
    
    private func initializePickerView() {
        lanPicker.delegate = self
        lanPicker.dataSource = self
        
        lanPicker.selectRow(1, inComponent: 1, animated: true)
    }
    
    private func initializeTextView() {
        originLanTextView.delegate = self
        transLanTextView.delegate = self
    }
    
    private func registerGestureRecognizer() {
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - Actions
    
    private func translated() {
        guard let text = originLanTextView.text, text != "" else {
            transLanTextView.text = ""
            return
        }
        
        let srcLan = selectLanguage[lanPicker.selectedRow(inComponent: 0)].mark
        let targetLan = selectLanguage[lanPicker.selectedRow(inComponent: 1)].mark
        
        queryService.getTransResults(text, srcLan: srcLan, targetLan: targetLan) { result in
            DispatchQueue.main.async {
                self.transLanTextView.text = result
            }
        }
    }
    
    @IBAction func transButtonPressed(_ sender: UIButton) {
        translated()
    }
    
    @objc func dismissKeyboard() {
        originLanTextView.resignFirstResponder()
        transLanTextView.resignFirstResponder()
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: - UIPickerViewDelegate
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return selectLanguage.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return selectLanguage[row].lan
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            originLanLabel.text = selectLanguage[row].lan
        } else {
            transLanLabel.text = selectLanguage[row].lan
        }
    }
}

extension ViewController: UITextViewDelegate {
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            translated()
        }
        return true
    }
    
}
