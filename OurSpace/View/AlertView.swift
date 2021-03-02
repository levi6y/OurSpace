//
//  AlertView.swift
//  OurSpace
//
//  Created by levi6y on 2021/2/4.
//

import SwiftUI

func alertView(msg: String,completion: @escaping (String) -> ()){
    
    
    if (msg == "username"){
        let alert = UIAlertController(title: "Update Username", message: msg, preferredStyle: .alert)
        alert.addTextField { (txt) in
            txt.placeholder = msg.contains("Verification") ? "123456" : ""
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.addAction(UIAlertAction(title: msg.contains("Verification") ? "Verify" : "Update", style: .default, handler: { (_) in
            
            let code = alert.textFields![0].text ?? ""
            
            if code == ""{
                
                UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
                return
            }
            completion(code)
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }else if(msg == "delete"){
        let alert = UIAlertController(title: "Delete Space", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.addAction(UIAlertAction(title: msg.contains("Verification") ? "Verify" : "Delete", style: .default, handler: { (_) in
            
            
            completion("delete")
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }else if(msg == "sign out"){
        let alert = UIAlertController(title: "Sign Out?", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.addAction(UIAlertAction(title: msg.contains("Verification") ? "Verify" : "Yes", style: .default, handler: { (_) in
            
            
            completion("sign out")
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }else if(msg == "deletePhoto"){
        let alert = UIAlertController(title: "Delete this photo?", message: "", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive))
        
        alert.addAction(UIAlertAction(title: msg.contains("Verification") ? "Verify" : "Yes", style: .default, handler: { (_) in
            
            
            completion("delete")
        }))
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true)
    }
    
    
    
}
