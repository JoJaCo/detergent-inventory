//
//  InvoiceGenerator.swift
//  Detergent Inventory
//
//  Created by Jorge Contreras Jr on 10/12/26.
//

import UIKit

struct InvoiceGenerator {
    
    /// Builds a PDF invoice from a Sale and returns the file URL.
    /// - Parameters:
    ///   - sale: The sale to invoice.
    ///   - companyName: The company name to display at the top.
    static func makePDF(for sale: Sale, companyName: String) -> URL? {
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 48
        
        let renderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight))
        
        let fileName = "invoice-\(invoiceNumber(for: sale)).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        do {
            try renderer.writePDF(to: url) { context in
                context.beginPage()
                drawInvoice(sale: sale,
                            companyName: companyName,
                            pageWidth: pageWidth,
                            pageHeight: pageHeight,
                            margin: margin)
            }
            return url
        } catch {
            print("Invoice PDF error: \(error)")
            return nil
        }
    }
    // MARK: - Invoice Number
    
    /// Derives a short readable invoice number from the sale ID and date.
    static func invoiceNumber(for sale: Sale) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let datePart = formatter.string(from: sale.date)
        let idPart = String(sale.id.uuidString.prefix(6)).uppercased()
        return "INV-\(datePart)-\(idPart)"
    }
    
    // MARK: - Drawing
    
    private static func drawInvoice(sale: Sale,
                                    companyName: String,
                                    pageWidth: CGFloat,
                                    pageHeight: CGFloat,
                                    margin: CGFloat) {
        let contentWidth = pageWidth - (margin * 2)
        var y: CGFloat = margin
        
        // MARK: Company Name (new)
        let companyAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
            .foregroundColor: UIColor.black,
            .kern: 1.5
        ]
        (companyName.uppercased() as NSString).draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: companyAttrs
        )
        
        y += 32
        
        // MARK: Header (existing "INVOICE" title)
        let title = "INVOICE"
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 28, weight: .bold),
            .foregroundColor: UIColor.black,
            .kern: 2.0
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: titleAttrs)
        
        // Invoice number (right-aligned)
        let invoiceNum = invoiceNumber(for: sale)
        let invoiceAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        let invoiceSize = (invoiceNum as NSString).size(withAttributes: invoiceAttrs)
        (invoiceNum as NSString).draw(
            at: CGPoint(x: pageWidth - margin - invoiceSize.width, y: y + 12),
            withAttributes: invoiceAttrs
        )
        
        y += 50
        
        
        // Divider
        drawLine(from: CGPoint(x: margin, y: y), to: CGPoint(x: pageWidth - margin, y: y), width: 2)
        y += 24
        
        // MARK: Bill To / Date
        let labelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.darkGray,
            .kern: 1.5
        ]
        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        
        let halfWidth = contentWidth / 2
        
        // Left column: Bill To
        ("BILL TO" as NSString).draw(at: CGPoint(x: margin, y: y), withAttributes: labelAttrs)
        ("\(sale.clientName)" as NSString).draw(
            at: CGPoint(x: margin, y: y + 18),
            withAttributes: [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
        )
        if !sale.clientAddress.isEmpty {
            drawWrappedText(sale.clientAddress,
                            in: CGRect(x: margin, y: y + 38, width: halfWidth - 12, height: 60),
                            attributes: valueAttrs)
        }
        
        // Right column: Date / Payment
        let rightX = margin + halfWidth
        ("DATE" as NSString).draw(at: CGPoint(x: rightX, y: y), withAttributes: labelAttrs)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        (dateFormatter.string(from: sale.date) as NSString).draw(
            at: CGPoint(x: rightX, y: y + 18),
            withAttributes: valueAttrs
        )
        
        ("PAYMENT METHOD" as NSString).draw(at: CGPoint(x: rightX, y: y + 44), withAttributes: labelAttrs)
        (sale.paymentMethod as NSString).draw(
            at: CGPoint(x: rightX, y: y + 62),
            withAttributes: valueAttrs
        )
        
        y += 110
        
        // MARK: Items Table Header
        drawLine(from: CGPoint(x: margin, y: y), to: CGPoint(x: pageWidth - margin, y: y), width: 1)
        y += 10
        
        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.black,
            .kern: 1.2
        ]
        
        let colProduct = margin
        let colQty = margin + contentWidth * 0.55
        let colPrice = margin + contentWidth * 0.70
        let colSubtotal = margin + contentWidth * 0.85
        
        ("PRODUCT" as NSString).draw(at: CGPoint(x: colProduct, y: y), withAttributes: headerAttrs)
        ("QTY" as NSString).draw(at: CGPoint(x: colQty, y: y), withAttributes: headerAttrs)
        ("PRICE" as NSString).draw(at: CGPoint(x: colPrice, y: y), withAttributes: headerAttrs)
        ("SUBTOTAL" as NSString).draw(at: CGPoint(x: colSubtotal, y: y), withAttributes: headerAttrs)
        
        y += 20
        drawLine(from: CGPoint(x: margin, y: y), to: CGPoint(x: pageWidth - margin, y: y), width: 1)
        y += 12
        
        // MARK: Items Rows
        let rowAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.black
        ]
        let rowNameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.black
        ]
        
        for item in sale.lineItems {
            // Product name
            drawWrappedText(item.productName,
                            in: CGRect(x: colProduct, y: y, width: colQty - colProduct - 12, height: 40),
                            attributes: rowNameAttrs)
            
            // Qty (right-aligned)
            let qtyStr = "\(item.quantity)"
            let qtySize = (qtyStr as NSString).size(withAttributes: rowAttrs)
            (qtyStr as NSString).draw(at: CGPoint(x: colQty + 30 - qtySize.width, y: y),
                                      withAttributes: rowAttrs)
            
            // Price
            let priceStr = "$\(String(format: "%.2f", item.pricePerUnit))"
            (priceStr as NSString).draw(at: CGPoint(x: colPrice, y: y), withAttributes: rowAttrs)
            
            // Subtotal
            let subStr = "$\(String(format: "%.2f", item.subtotal))"
            (subStr as NSString).draw(at: CGPoint(x: colSubtotal, y: y), withAttributes: rowAttrs)
            
            y += 24
        }
        
        y += 12
        drawLine(from: CGPoint(x: margin, y: y), to: CGPoint(x: pageWidth - margin, y: y), width: 1)
        y += 16
        
        // MARK: Total
        let totalLabelAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14, weight: .bold),
            .foregroundColor: UIColor.black,
            .kern: 2.0
        ]
        let totalValueAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        
        let totalLabelX = margin + contentWidth * 0.55
        ("TOTAL" as NSString).draw(at: CGPoint(x: totalLabelX, y: y + 4), withAttributes: totalLabelAttrs)
        
        let totalStr = "$\(String(format: "%.2f", sale.total))"
        let totalSize = (totalStr as NSString).size(withAttributes: totalValueAttrs)
        (totalStr as NSString).draw(
            at: CGPoint(x: pageWidth - margin - totalSize.width, y: y - 4),
            withAttributes: totalValueAttrs
        )
        
        // MARK: Footer
        let footerY = pageHeight - margin - 20
        let footerAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.darkGray
        ]
        ("Thank you for your business." as NSString).draw(
            at: CGPoint(x: margin, y: footerY),
            withAttributes: footerAttrs
        )
    }
    
    // MARK: - Drawing Helpers
    
    private static func drawLine(from: CGPoint, to: CGPoint, width: CGFloat) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.setStrokeColor(UIColor.black.cgColor)
        ctx.setLineWidth(width)
        ctx.move(to: from)
        ctx.addLine(to: to)
        ctx.strokePath()
    }
    
    private static func drawWrappedText(_ text: String,
                                        in rect: CGRect,
                                        attributes: [NSAttributedString.Key: Any]) {
        let attrString = NSAttributedString(string: text, attributes: attributes)
        attrString.draw(with: rect,
                        options: [.usesLineFragmentOrigin, .usesFontLeading],
                        context: nil)
    }
}
