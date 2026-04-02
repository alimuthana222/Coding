from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor

def create_medical_drone_presentation():
    # Create presentation object
    prs = Presentation()
    prs.slide_width = Inches(10)
    prs.slide_height = Inches(7.5)

    # Define modern color scheme
    PRIMARY_COLOR = RGBColor(0, 120, 212)  # Modern blue
    ACCENT_COLOR = RGBColor(0, 178, 148)   # Teal
    DARK_COLOR = RGBColor(32, 33, 36)      # Dark gray
    LIGHT_COLOR = RGBColor(245, 245, 245)  # Light gray
    WHITE = RGBColor(255, 255, 255)

    # Slide 1: Title Slide
    slide1 = prs.slides.add_slide(prs.slide_layouts[6])  # Blank layout

    # Add background color
    background = slide1.background
    fill = background.fill
    fill.solid()
    fill.fore_color.rgb = PRIMARY_COLOR

    # Add title
    title_box = slide1.shapes.add_textbox(Inches(0.5), Inches(2.5), Inches(9), Inches(1))
    title_frame = title_box.text_frame
    title_frame.text = "MEDICAL SUPPLIES DELIVERY DRONE"
    title_para = title_frame.paragraphs[0]
    title_para.font.size = Pt(54)
    title_para.font.bold = True
    title_para.font.color.rgb = WHITE
    title_para.alignment = PP_ALIGN.CENTER

    # Add subtitle
    subtitle_box = slide1.shapes.add_textbox(Inches(0.5), Inches(3.8), Inches(9), Inches(0.8))
    subtitle_frame = subtitle_box.text_frame
    subtitle_frame.text = "Revolutionizing Healthcare Logistics"
    subtitle_para = subtitle_frame.paragraphs[0]
    subtitle_para.font.size = Pt(28)
    subtitle_para.font.color.rgb = LIGHT_COLOR
    subtitle_para.alignment = PP_ALIGN.CENTER

    # Add date/info
    info_box = slide1.shapes.add_textbox(Inches(0.5), Inches(6.5), Inches(9), Inches(0.5))
    info_frame = info_box.text_frame
    info_frame.text = "2026 • Next-Generation Healthcare Solutions"
    info_para = info_frame.paragraphs[0]
    info_para.font.size = Pt(18)
    info_para.font.color.rgb = ACCENT_COLOR
    info_para.alignment = PP_ALIGN.CENTER

    # Slide 2: Executive Summary
    slide2 = prs.slides.add_slide(prs.slide_layouts[6])

    # Add header
    header2 = slide2.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header2_frame = header2.text_frame
    header2_frame.text = "EXECUTIVE SUMMARY"
    header2_para = header2_frame.paragraphs[0]
    header2_para.font.size = Pt(36)
    header2_para.font.bold = True
    header2_para.font.color.rgb = PRIMARY_COLOR

    # Add content
    content2 = slide2.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf2 = content2.text_frame
    tf2.word_wrap = True

    points = [
        ("Challenge", "Traditional medical supply delivery faces delays, accessibility issues, and high costs in remote areas"),
        ("Solution", "Autonomous drones providing rapid, reliable delivery of critical medical supplies to underserved regions"),
        ("Impact", "Reduced delivery time from hours to minutes, saving lives in emergency situations"),
        ("Technology", "AI-powered navigation, temperature-controlled cargo, and real-time tracking systems"),
        ("Sustainability", "Zero-emission electric propulsion reducing healthcare's carbon footprint")
    ]

    for title, desc in points:
        p = tf2.add_paragraph()
        p.text = f"{title}: "
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(6)

        run = p.runs[0]
        run.text += desc
        run.font.bold = False
        run.font.color.rgb = DARK_COLOR

        p.level = 0
        p.space_after = Pt(15)

    # Slide 3: Market Need
    slide3 = prs.slides.add_slide(prs.slide_layouts[6])

    header3 = slide3.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header3_frame = header3.text_frame
    header3_frame.text = "MARKET NEED & OPPORTUNITY"
    header3_para = header3_frame.paragraphs[0]
    header3_para.font.size = Pt(36)
    header3_para.font.bold = True
    header3_para.font.color.rgb = PRIMARY_COLOR

    content3 = slide3.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf3 = content3.text_frame
    tf3.word_wrap = True

    needs = [
        "2 billion people lack access to essential medicines globally",
        "Remote areas face 3-5 day delays for critical medical supplies",
        "Emergency medical situations require <30 minute response times",
        "$8.5 billion annual cost of medical supply chain inefficiencies",
        "Limited cold-chain infrastructure in developing regions",
        "Growing demand for contactless delivery post-pandemic"
    ]

    for need in needs:
        p = tf3.add_paragraph()
        p.text = need
        p.font.size = Pt(18)
        p.font.color.rgb = DARK_COLOR
        p.level = 0
        p.space_before = Pt(12)
        p.space_after = Pt(12)
        # Add bullet
        p.text = "• " + p.text

    # Slide 4: Technical Specifications
    slide4 = prs.slides.add_slide(prs.slide_layouts[6])

    header4 = slide4.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header4_frame = header4.text_frame
    header4_frame.text = "TECHNICAL SPECIFICATIONS"
    header4_para = header4_frame.paragraphs[0]
    header4_para.font.size = Pt(36)
    header4_para.font.bold = True
    header4_para.font.color.rgb = PRIMARY_COLOR

    # Create two columns
    left_col = slide4.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(4), Inches(5.5))
    tf_left = left_col.text_frame
    tf_left.word_wrap = True

    left_specs = [
        ("Flight Range", "100 km (62 miles)"),
        ("Maximum Speed", "120 km/h (75 mph)"),
        ("Payload Capacity", "5 kg (11 lbs)"),
        ("Flight Time", "45 minutes"),
        ("Operating Altitude", "120 m (400 ft)")
    ]

    for spec_title, spec_value in left_specs:
        p = tf_left.add_paragraph()
        p.text = spec_title
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(4)

        p2 = tf_left.add_paragraph()
        p2.text = spec_value
        p2.font.size = Pt(14)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(18)

    right_col = slide4.shapes.add_textbox(Inches(5.3), Inches(1.3), Inches(4), Inches(5.5))
    tf_right = right_col.text_frame
    tf_right.word_wrap = True

    right_specs = [
        ("Temperature Control", "-20°C to +8°C"),
        ("Navigation", "GPS + AI Vision"),
        ("Communication", "4G/5G + Satellite"),
        ("Weather Resistance", "IP67 Rated"),
        ("Battery", "Lithium-ion, Quick-charge")
    ]

    for spec_title, spec_value in right_specs:
        p = tf_right.add_paragraph()
        p.text = spec_title
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(4)

        p2 = tf_right.add_paragraph()
        p2.text = spec_value
        p2.font.size = Pt(14)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(18)

    # Slide 5: Key Features
    slide5 = prs.slides.add_slide(prs.slide_layouts[6])

    header5 = slide5.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header5_frame = header5.text_frame
    header5_frame.text = "KEY FEATURES"
    header5_para = header5_frame.paragraphs[0]
    header5_para.font.size = Pt(36)
    header5_para.font.bold = True
    header5_para.font.color.rgb = PRIMARY_COLOR

    # Create feature boxes
    features = [
        ("🎯 Autonomous Navigation", "AI-powered obstacle avoidance and route optimization"),
        ("❄️ Cold Chain Management", "Maintains vaccine and medicine integrity"),
        ("📡 Real-Time Tracking", "Live GPS monitoring and delivery notifications"),
        ("🔒 Secure Payload", "Tamper-proof containers with digital verification"),
        ("⚡ Rapid Deployment", "Launches within 5 minutes of order"),
        ("🌧️ All-Weather Operation", "Operates in rain, wind, and low visibility")
    ]

    y_pos = 1.3
    for i, (title, desc) in enumerate(features):
        if i % 2 == 0:
            x_pos = 0.7
        else:
            x_pos = 5.1

        # Feature box
        box = slide5.shapes.add_textbox(Inches(x_pos), Inches(y_pos), Inches(4), Inches(1.2))
        tf_box = box.text_frame
        tf_box.word_wrap = True

        p_title = tf_box.paragraphs[0]
        p_title.text = title
        p_title.font.size = Pt(16)
        p_title.font.bold = True
        p_title.font.color.rgb = PRIMARY_COLOR
        p_title.space_after = Pt(6)

        p_desc = tf_box.add_paragraph()
        p_desc.text = desc
        p_desc.font.size = Pt(12)
        p_desc.font.color.rgb = DARK_COLOR

        if i % 2 == 1:
            y_pos += 1.5

    # Slide 6: Use Cases
    slide6 = prs.slides.add_slide(prs.slide_layouts[6])

    header6 = slide6.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header6_frame = header6.text_frame
    header6_frame.text = "USE CASES & APPLICATIONS"
    header6_para = header6_frame.paragraphs[0]
    header6_para.font.size = Pt(36)
    header6_para.font.bold = True
    header6_para.font.color.rgb = PRIMARY_COLOR

    content6 = slide6.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf6 = content6.text_frame
    tf6.word_wrap = True

    use_cases = [
        ("Emergency Medical Response", "Deliver life-saving medications, defibrillators, and blood products to accident sites"),
        ("Rural Healthcare Access", "Routine medication delivery to remote villages and underserved communities"),
        ("Vaccine Distribution", "Temperature-controlled vaccine transport for immunization programs"),
        ("Hospital Network", "Inter-facility transfer of lab samples, blood units, and critical supplies"),
        ("Disaster Relief", "Rapid deployment of medical aid in natural disasters and conflict zones"),
        ("Organ Transport", "Time-critical delivery of organs for transplantation")
    ]

    for title, desc in use_cases:
        p = tf6.add_paragraph()
        p.text = title
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(4)

        p2 = tf6.add_paragraph()
        p2.text = desc
        p2.font.size = Pt(13)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(15)

    # Slide 7: Benefits
    slide7 = prs.slides.add_slide(prs.slide_layouts[6])

    header7 = slide7.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header7_frame = header7.text_frame
    header7_frame.text = "KEY BENEFITS"
    header7_para = header7_frame.paragraphs[0]
    header7_para.font.size = Pt(36)
    header7_para.font.bold = True
    header7_para.font.color.rgb = PRIMARY_COLOR

    # Create benefit cards
    benefits = [
        ("Speed", "60x faster than ground transport", PRIMARY_COLOR),
        ("Cost", "70% reduction in delivery costs", ACCENT_COLOR),
        ("Reliability", "99.5% successful delivery rate", PRIMARY_COLOR),
        ("Lives Saved", "Reduces emergency response time by 80%", ACCENT_COLOR)
    ]

    x_positions = [0.7, 5.1, 0.7, 5.1]
    y_positions = [1.5, 1.5, 4.2, 4.2]

    for i, (title, desc, color) in enumerate(benefits):
        box = slide7.shapes.add_textbox(Inches(x_positions[i]), Inches(y_positions[i]), Inches(3.8), Inches(2))
        tf_box = box.text_frame
        tf_box.word_wrap = True
        tf_box.vertical_anchor = MSO_ANCHOR.MIDDLE

        p_title = tf_box.paragraphs[0]
        p_title.text = title
        p_title.font.size = Pt(24)
        p_title.font.bold = True
        p_title.font.color.rgb = color
        p_title.alignment = PP_ALIGN.CENTER
        p_title.space_after = Pt(10)

        p_desc = tf_box.add_paragraph()
        p_desc.text = desc
        p_desc.font.size = Pt(16)
        p_desc.font.color.rgb = DARK_COLOR
        p_desc.alignment = PP_ALIGN.CENTER

    # Slide 8: Safety & Regulations
    slide8 = prs.slides.add_slide(prs.slide_layouts[6])

    header8 = slide8.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header8_frame = header8.text_frame
    header8_frame.text = "SAFETY & REGULATORY COMPLIANCE"
    header8_para = header8_frame.paragraphs[0]
    header8_para.font.size = Pt(36)
    header8_para.font.bold = True
    header8_para.font.color.rgb = PRIMARY_COLOR

    content8 = slide8.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf8 = content8.text_frame
    tf8.word_wrap = True

    safety_points = [
        "FAA Part 107 and international aviation authority certified",
        "Redundant flight systems with automatic emergency landing",
        "Geofencing to prevent unauthorized zone access",
        "Real-time weather monitoring and route adjustment",
        "Collision avoidance using LIDAR and computer vision",
        "Encrypted communication channels for data security",
        "HIPAA-compliant patient information handling",
        "Regular maintenance and pre-flight safety checks"
    ]

    for point in safety_points:
        p = tf8.add_paragraph()
        p.text = "✓ " + point
        p.font.size = Pt(16)
        p.font.color.rgb = DARK_COLOR
        p.level = 0
        p.space_before = Pt(8)
        p.space_after = Pt(8)

    # Slide 9: Environmental Impact
    slide9 = prs.slides.add_slide(prs.slide_layouts[6])

    header9 = slide9.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header9_frame = header9.text_frame
    header9_frame.text = "ENVIRONMENTAL IMPACT"
    header9_para = header9_frame.paragraphs[0]
    header9_para.font.size = Pt(36)
    header9_para.font.bold = True
    header9_para.font.color.rgb = PRIMARY_COLOR

    content9 = slide9.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf9 = content9.text_frame
    tf9.word_wrap = True

    env_sections = [
        ("Zero Direct Emissions", "100% electric propulsion system with no fossil fuel consumption"),
        ("Carbon Footprint Reduction", "95% lower CO2 emissions compared to traditional vehicle delivery"),
        ("Renewable Energy Integration", "Solar-powered charging stations at deployment hubs"),
        ("Noise Pollution", "Whisper-quiet operation at 60 dB, suitable for residential areas"),
        ("Sustainable Materials", "Recyclable components and biodegradable packaging options"),
        ("Resource Efficiency", "Optimized routes reduce overall energy consumption by 80%")
    ]

    for title, desc in env_sections:
        p = tf9.add_paragraph()
        p.text = title
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(4)

        p2 = tf9.add_paragraph()
        p2.text = desc
        p2.font.size = Pt(13)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(12)

    # Slide 10: Implementation Timeline
    slide10 = prs.slides.add_slide(prs.slide_layouts[6])

    header10 = slide10.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header10_frame = header10.text_frame
    header10_frame.text = "IMPLEMENTATION ROADMAP"
    header10_para = header10_frame.paragraphs[0]
    header10_para.font.size = Pt(36)
    header10_para.font.bold = True
    header10_para.font.color.rgb = PRIMARY_COLOR

    content10 = slide10.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf10 = content10.text_frame
    tf10.word_wrap = True

    phases = [
        ("Phase 1: Pilot Program", "• Initial deployment in 3 test regions\n• 50 drones serving 100,000 people\n• Data collection and system optimization"),
        ("Phase 2: Regional Expansion", "• Scale to 10 regions across multiple countries\n• Fleet expansion to 500 drones\n• Partnership with healthcare providers"),
        ("Phase 3: National Coverage", "• Nationwide rollout in partner countries\n• 5,000 drones in operation\n• Integration with national health systems"),
        ("Phase 4: Global Network", "• International operations in 50+ countries\n• 50,000+ drones worldwide\n• Full automation and AI optimization")
    ]

    for title, desc in phases:
        p = tf10.add_paragraph()
        p.text = title
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = PRIMARY_COLOR
        p.space_after = Pt(6)

        p2 = tf10.add_paragraph()
        p2.text = desc
        p2.font.size = Pt(12)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(14)

    # Slide 11: Financial Projections
    slide11 = prs.slides.add_slide(prs.slide_layouts[6])

    header11 = slide11.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header11_frame = header11.text_frame
    header11_frame.text = "FINANCIAL OVERVIEW"
    header11_para = header11_frame.paragraphs[0]
    header11_para.font.size = Pt(36)
    header11_para.font.bold = True
    header11_para.font.color.rgb = PRIMARY_COLOR

    # Left column - Costs
    left_fin = slide11.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(4), Inches(5.5))
    tf_left_fin = left_fin.text_frame
    tf_left_fin.word_wrap = True

    p_cost_title = tf_left_fin.paragraphs[0]
    p_cost_title.text = "Cost Structure"
    p_cost_title.font.size = Pt(22)
    p_cost_title.font.bold = True
    p_cost_title.font.color.rgb = PRIMARY_COLOR
    p_cost_title.space_after = Pt(15)

    costs = [
        ("Initial Investment", "$2.5M per deployment hub"),
        ("Drone Unit Cost", "$25,000 per unit"),
        ("Operating Cost", "$0.50 per delivery"),
        ("Maintenance", "$500/month per drone"),
        ("Insurance", "$1,000/year per drone")
    ]

    for cost_title, cost_value in costs:
        p = tf_left_fin.add_paragraph()
        p.text = cost_title
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = DARK_COLOR
        p.space_after = Pt(3)

        p2 = tf_left_fin.add_paragraph()
        p2.text = cost_value
        p2.font.size = Pt(13)
        p2.font.color.rgb = ACCENT_COLOR
        p2.space_after = Pt(12)

    # Right column - Revenue
    right_fin = slide11.shapes.add_textbox(Inches(5.3), Inches(1.3), Inches(4), Inches(5.5))
    tf_right_fin = right_fin.text_frame
    tf_right_fin.word_wrap = True

    p_rev_title = tf_right_fin.paragraphs[0]
    p_rev_title.text = "Revenue Model"
    p_rev_title.font.size = Pt(22)
    p_rev_title.font.bold = True
    p_rev_title.font.color.rgb = PRIMARY_COLOR
    p_rev_title.space_after = Pt(15)

    revenues = [
        ("Per Delivery Fee", "$15-25 per delivery"),
        ("Subscription Model", "$500/month for hospitals"),
        ("Government Contracts", "$5M annual programs"),
        ("Break-even Point", "18 months"),
        ("ROI", "300% over 5 years")
    ]

    for rev_title, rev_value in revenues:
        p = tf_right_fin.add_paragraph()
        p.text = rev_title
        p.font.size = Pt(14)
        p.font.bold = True
        p.font.color.rgb = DARK_COLOR
        p.space_after = Pt(3)

        p2 = tf_right_fin.add_paragraph()
        p2.text = rev_value
        p2.font.size = Pt(13)
        p2.font.color.rgb = ACCENT_COLOR
        p2.space_after = Pt(12)

    # Slide 12: Competitive Advantage
    slide12 = prs.slides.add_slide(prs.slide_layouts[6])

    header12 = slide12.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header12_frame = header12.text_frame
    header12_frame.text = "COMPETITIVE ADVANTAGE"
    header12_para = header12_frame.paragraphs[0]
    header12_para.font.size = Pt(36)
    header12_para.font.bold = True
    header12_para.font.color.rgb = PRIMARY_COLOR

    content12 = slide12.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf12 = content12.text_frame
    tf12.word_wrap = True

    advantages = [
        ("Advanced AI Navigation", "Proprietary machine learning algorithms for optimal route planning"),
        ("Medical-Grade Certification", "Only drone system certified for pharmaceutical transport"),
        ("Temperature Precision", "±0.5°C accuracy in cold-chain management"),
        ("Extended Range", "2x the range of competing systems"),
        ("Rapid Deployment", "5-minute launch vs. 30-minute industry average"),
        ("Healthcare Integration", "Seamless EMR and hospital system connectivity"),
        ("Proven Track Record", "10,000+ successful medical deliveries completed"),
        ("Strategic Partnerships", "Collaborations with WHO, Red Cross, and major hospitals")
    ]

    for title, desc in advantages:
        p = tf12.add_paragraph()
        p.text = title
        p.font.size = Pt(15)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(4)

        p2 = tf12.add_paragraph()
        p2.text = desc
        p2.font.size = Pt(13)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(12)

    # Slide 13: Success Stories
    slide13 = prs.slides.add_slide(prs.slide_layouts[6])

    header13 = slide13.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header13_frame = header13.text_frame
    header13_frame.text = "SUCCESS STORIES"
    header13_para = header13_frame.paragraphs[0]
    header13_para.font.size = Pt(36)
    header13_para.font.bold = True
    header13_para.font.color.rgb = PRIMARY_COLOR

    content13 = slide13.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf13 = content13.text_frame
    tf13.word_wrap = True

    stories = [
        ("Rural Rwanda Vaccine Program", "Delivered 15,000 vaccine doses to 50+ remote health centers, achieving 98% immunization coverage in previously underserved areas."),
        ("Hurricane Response - Caribbean", "Provided critical medical supplies to 5,000 isolated residents within 48 hours of disaster, when roads were impassable."),
        ("Remote Island Healthcare - Pacific", "Established reliable medication delivery to 20 island communities, reducing patient wait times from weeks to hours."),
        ("Urban Emergency Services - Europe", "Delivered defibrillators to cardiac emergency sites, contributing to 40% increase in survival rates.")
    ]

    for title, desc in stories:
        p = tf13.add_paragraph()
        p.text = title
        p.font.size = Pt(16)
        p.font.bold = True
        p.font.color.rgb = PRIMARY_COLOR
        p.space_after = Pt(6)

        p2 = tf13.add_paragraph()
        p2.text = desc
        p2.font.size = Pt(13)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(16)

    # Slide 14: Future Innovations
    slide14 = prs.slides.add_slide(prs.slide_layouts[6])

    header14 = slide14.shapes.add_textbox(Inches(0.5), Inches(0.3), Inches(9), Inches(0.6))
    header14_frame = header14.text_frame
    header14_frame.text = "FUTURE INNOVATIONS"
    header14_para = header14_frame.paragraphs[0]
    header14_para.font.size = Pt(36)
    header14_para.font.bold = True
    header14_para.font.color.rgb = PRIMARY_COLOR

    content14 = slide14.shapes.add_textbox(Inches(0.7), Inches(1.3), Inches(8.6), Inches(5.5))
    tf14 = content14.text_frame
    tf14.word_wrap = True

    innovations = [
        ("AI-Powered Predictive Analytics", "Forecast medical supply needs before shortages occur"),
        ("Swarm Technology", "Coordinate multiple drones for mass vaccination campaigns"),
        ("Extended Range Models", "300km range for international cross-border deliveries"),
        ("Vertical Take-off & Landing", "Hospital rooftop integration without landing pads"),
        ("Autonomous Maintenance", "Self-diagnosing systems with predictive repair scheduling"),
        ("5G/6G Integration", "Ultra-low latency control and high-definition monitoring"),
        ("Hydrogen Fuel Cells", "Extended flight time up to 4 hours per mission"),
        ("Modular Payload Systems", "Configurable cargo bays for various medical equipment")
    ]

    for title, desc in innovations:
        p = tf14.add_paragraph()
        p.text = "→ " + title
        p.font.size = Pt(15)
        p.font.bold = True
        p.font.color.rgb = ACCENT_COLOR
        p.space_after = Pt(4)

        p2 = tf14.add_paragraph()
        p2.text = "   " + desc
        p2.font.size = Pt(12)
        p2.font.color.rgb = DARK_COLOR
        p2.space_after = Pt(10)

    # Slide 15: Call to Action
    slide15 = prs.slides.add_slide(prs.slide_layouts[6])

    # Add background color
    background15 = slide15.background
    fill15 = background15.fill
    fill15.solid()
    fill15.fore_color.rgb = ACCENT_COLOR

    # Add main message
    cta_title = slide15.shapes.add_textbox(Inches(0.5), Inches(2.2), Inches(9), Inches(1.2))
    cta_title_frame = cta_title.text_frame
    cta_title_frame.text = "JOIN THE REVOLUTION IN HEALTHCARE DELIVERY"
    cta_title_para = cta_title_frame.paragraphs[0]
    cta_title_para.font.size = Pt(40)
    cta_title_para.font.bold = True
    cta_title_para.font.color.rgb = WHITE
    cta_title_para.alignment = PP_ALIGN.CENTER

    # Add sub-message
    cta_sub = slide15.shapes.add_textbox(Inches(0.5), Inches(3.8), Inches(9), Inches(1.5))
    cta_sub_frame = cta_sub.text_frame
    cta_sub_frame.text = "Together, we can save lives and transform healthcare access\nfor millions of people worldwide"
    cta_sub_para = cta_sub_frame.paragraphs[0]
    cta_sub_para.font.size = Pt(24)
    cta_sub_para.font.color.rgb = WHITE
    cta_sub_para.alignment = PP_ALIGN.CENTER
    cta_sub_para.line_spacing = 1.4

    # Add contact info
    contact_box = slide15.shapes.add_textbox(Inches(0.5), Inches(5.8), Inches(9), Inches(1))
    contact_frame = contact_box.text_frame
    contact_frame.text = "Contact: healthcare@dronesolutions.com | www.medicaldrones.com"
    contact_para = contact_frame.paragraphs[0]
    contact_para.font.size = Pt(18)
    contact_para.font.color.rgb = WHITE
    contact_para.alignment = PP_ALIGN.CENTER

    # Save the presentation
    prs.save('/home/runner/work/Coding/Coding/Medical_Supplies_Delivery_Drone.pptx')
    print("✓ Presentation created successfully: Medical_Supplies_Delivery_Drone.pptx")
    print(f"✓ Total slides: {len(prs.slides)}")
    print("✓ Modern design applied with professional color scheme")

if __name__ == "__main__":
    create_medical_drone_presentation()
