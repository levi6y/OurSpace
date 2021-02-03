//
//  AlertView.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/4.
//

import SwiftUI

func alertView(msg: String,completion: @escaping (String) -> ()){
    
    let alert = UIAlertController(title: "Update Username", message: msg, preferredStyle: .alert)
    
    alert.addTextField { (txt) in
        txt.placeholder = msg.contains("Verification") ? "123456" : ""
    }
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
    
    alert.addAction(UIAlertAction(title: msg.contains("Verification") ? "Verify" : "Update", style: .default, handler: { (_) in
        
        let code = alert.textFields![0].text ?? ""
        
        if code == ""{
            // Repromoting..
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
            return
        }
        completion(code)
    }))
    
    UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
}
