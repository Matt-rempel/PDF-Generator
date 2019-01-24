//
//  ViewController.swift
//  PDF Invoice Generator
//
//  Created by Matthew Rempel on 2019-01-24.
//  Copyright © 2019 Matthew Rempel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIDocumentInteractionControllerDelegate {

    var cartSubtotal:Double! = 0.00
    var cartGST:Double! = 0.00
    var cartTotal:Double! = 0.00
    
    lazy var cartItems:[cartItem]! = [cartItem(itemTitle: "Apples", itemPrice: 1.99, itemQuantity: 2),
                                      cartItem(itemTitle: "Bananas", itemPrice: 3.99, itemQuantity: 1),
                                      cartItem(itemTitle: "Poutine", itemPrice: 5.99, itemQuantity: 2) ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculateCartTotal()
    }

    @IBAction func createPDFButtonTapped(_ sender: Any) {
        // Putting createPDF() in viewDidLoad() will not allow the preview window to show since the view will not be in the window hierarchy, hence we put create() in viewDidAppear
        createPDF()
    }
    
    func calculateCartTotal() {
        // Calculate Cart Totals
        for i in cartItems {
            cartSubtotal += (i.price * Double(i.quantity))
        }
        // Use adjust your tax percent accordingly
        cartGST = cartSubtotal * 0.05
        cartTotal = cartGST + cartSubtotal
        
        // Round all output to 2 decimal places
        cartSubtotal = round(100*cartSubtotal)/100
        cartGST = round(100*cartGST)/100
        cartTotal = round(100*cartTotal)/100
    }
    
    func createPDF() {
        // Pull data from the MaintenanceLogMaster Static info
        let html = getHTML()
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        pdfData.write(toFile: "\(documentsPath)/Invoice.pdf", atomically: true)
        
        self.previewPDF()
    }
    
    func previewPDF() {
        // DOCUMENT PREVIEWER
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentoPath = (path as NSString).appendingPathComponent("Invoice.pdf")
        let dc = UIDocumentInteractionController(url: URL(fileURLWithPath: documentoPath))
        dc.delegate = self
        dc.presentPreview(animated: true)
    }
    
    
    //MARK: UIDocumentInteractionController delegates
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self//or use return self.navigationController for fetching app navigation bar colour
    }
    
    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController) {
        // Dismissed PDF Prewview
    }

    
    //MARK: HTML Helper Methods
    
    func getTableTags() -> String {
        var output = ""
        
        for i in 0...cartItems.count-1 {
            let item = cartItems[i]
        
            if i != cartItems.count-1 {
                for _ in 0...item.quantity-1 {
                    var tags = "<tr class='item'><td>" + item.title
                    tags += "</td><td>"
                    tags += "$\(item.price!)"
                    tags += "</td></tr>"
                    
                    output += tags
                }
            } else {
                for j in 0...item.quantity-1 {
                    // Check if item is not the last one in the list
                    if j != item.quantity-1 {
                        var tags = "<tr class='item'><td>" + item.title
                        tags += "</td><td>"
                        tags += "$\(item.price!)"
                        tags += "</td></tr>"
                        
                        output += tags
                    } else {
                        var tags = "<tr class='item last'><td>" + item.title
                        tags += "</td><td>"
                        tags += "$\(item.price!)"
                        tags += "</td></tr>"
                        
                        output += tags
                    }
                }
            }
        }
        
        return output
    }
    
    func getHTML() -> String{
        // get the current date and time
        let currentDateTime = Date()
        
        // initialize the date formatter and set the style
        let formatterDate = DateFormatter()
        //            formatter.timeStyle = .medium
        formatterDate.dateStyle = .long
        
        let formatterTime = DateFormatter()
        formatterTime.timeStyle = .short
        
        let currentDate = " " + formatterDate.string(from: currentDateTime) // October 8, 2016
        let html = """
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <style>
        .invoice-box {
            max-width: 800px;
            margin: auto;
            padding: 30px;
            border: 1px solid #eee;
            box-shadow: 0 0 10px rgba(0, 0, 0, .15);
            font-size: 16px;
            line-height: 24px;
            font-family: 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;
            color: #555;
        }

        .invoice-box table {
            width: 100%;
            line-height: inherit;
            text-align: left;
        }

        .invoice-box table td {
            padding: 5px;
            vertical-align: top;
        }

        .invoice-box table tr td:nth-child(2) {
            text-align: right;
        }

        .invoice-box table tr.top table td {
            padding-bottom: 20px;
        }

        .invoice-box table tr.top table td.title {
            font-size: 45px;
            line-height: 45px;
            color: #333;
        }

        .invoice-box table tr.information table td {
            padding-bottom: 40px;
        }

        .invoice-box table tr.heading td {
            background: #eee;
            border-bottom: 1px solid #ddd;
            font-weight: bold;
        }

        .invoice-box table tr.details td {
            padding-bottom: 20px;
        }

        .invoice-box table tr.item td {
            border-bottom: 1px solid #eee;
        }

        .invoice-box table tr.item.last td {
            border-bottom: none;
        }

        .invoice-box table tr.total td:nth-child(2) {
            border-top: 2px solid #eee;
            font-weight: bold;
        }

        @media only screen and (max-width: 600px) {
            .invoice-box table tr.top table td {
                width: 100%;
                display: block;
                text-align: center;
            }

            .invoice-box table tr.information table td {
                width: 100%;
                display: block;
                text-align: center;
            }
        }

        /** RTL **/
        .rtl {
            direction: rtl;
            font-family: Tahoma, 'Helvetica Neue', 'Helvetica', Helvetica, Arial, sans-serif;
        }

        .rtl table {
            text-align: right;
        }

        .rtl table tr td:nth-child(2) {
            text-align: left;
        }
    </style>
</head>

<body>
    <div class="invoice-box">
        <table cellpadding="0" cellspacing="0">
            <tr class="top">
                <td colspan="2">
                    <table>
                        <tr>
                            <td class="title">
                                
                            </td>

                            <td>
                                Created:
""" + currentDate + """
                                <br>
                                </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <tr class="information">
                <td colspan="2">
                    <table>
                        <tr>
                            <td>
                                Your Company, LTD.<br>
                                123 Street.<br>
                                Calgary, AB A1A1A1
                            </td>

                            <td>
                                First Last<br>
                                (123) 456-7890<br>
                                email@email.com
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>

            <tr class="heading">
                <td>
                    Item
                </td>

                <td>
                    Price
                </td>
            </tr>

            """ + getTableTags() + """
            
            <tr class="total">
                <td></td>

                <td>
                    Subtotal: $\(String(format:"%.2f", cartSubtotal))
                </td>
            </tr>

            <tr class="total">
                <td></td>

                <td>
                    GST: $\(String(format:"%.2f", cartGST))
                </td>
            </tr>
        
            <tr class="total">
                <td></td>

                <td>
                    Total: $\(String(format:"%.2f", cartTotal))
        </td>
        </tr>
        
        </table>
        </div>
        </body>
        
        </html>
        """
        
        return html
    }
}



