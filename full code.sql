-- STEP 1: DATABASE SCHEMA CREATION
CREATE DATABASE IF NOT EXISTS crm;
USE crm;

-- 1. SALES REPRESENTATIVES TABLE
CREATE TABLE sales_representatives (
    rep_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    territory VARCHAR(100),
    quota DECIMAL(12,2) DEFAULT 0.00,
    commission_rate DECIMAL(5,4) DEFAULT 0.0500,
    manager_id INT,
    status ENUM('Active', 'Inactive', 'On Leave') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_territory (territory),
    INDEX idx_status (status),
    FOREIGN KEY (manager_id) REFERENCES sales_representatives(rep_id) ON DELETE SET NULL
);

-- 2. CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    industry VARCHAR(50),
    website VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50) DEFAULT 'USA',
    postal_code VARCHAR(20),
    customer_type ENUM('Individual', 'Business', 'Enterprise') DEFAULT 'Individual',
    registration_date DATE NOT NULL,
    status ENUM('Active', 'Inactive', 'Prospect', 'Churned') DEFAULT 'Prospect',
    credit_limit DECIMAL(12,2) DEFAULT 5000.00,
    last_contact_date DATE,
    assigned_rep_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_company (company),
    INDEX idx_industry (industry),
    INDEX idx_status (status),
    INDEX idx_customer_type (customer_type),
    INDEX idx_email (email),
    FOREIGN KEY (assigned_rep_id) REFERENCES sales_representatives(rep_id) ON DELETE SET NULL
);

-- 3. LEADS TABLE
CREATE TABLE leads (
    lead_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(100),
    source ENUM('Website', 'Social Media', 'Email Campaign', 'Cold Call', 'Referral', 'Trade Show', 'Advertisement') NOT NULL,
    status ENUM('New', 'Contacted', 'Qualified', 'Converted', 'Disqualified') DEFAULT 'New',
    score INT DEFAULT 0,
    assigned_to INT,
    created_date DATE NOT NULL,
    converted_date DATE,
    estimated_value DECIMAL(12,2),
    notes TEXT,
    converted_customer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_source (source),
    INDEX idx_status (status),
    INDEX idx_score (score),
    FOREIGN KEY (assigned_to) REFERENCES sales_representatives(rep_id) ON DELETE SET NULL,
    FOREIGN KEY (converted_customer_id) REFERENCES customers(customer_id) ON DELETE SET NULL
);

-- 4. PRODUCTS TABLE
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    description TEXT,
    unit_price DECIMAL(10,2) NOT NULL,
    cost_price DECIMAL(10,2) NOT NULL,
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 10,
    supplier_id INT,
    status ENUM('Active', 'Discontinued', 'Out of Stock') DEFAULT 'Active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_product_name (product_name)
);

-- 5. ORDERS TABLE
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    rep_id INT,
    order_date DATE NOT NULL,
    expected_delivery DATE,
    status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned') DEFAULT 'Pending',
    total_amount DECIMAL(12,2) NOT NULL,
    discount DECIMAL(8,2) DEFAULT 0.00,
    tax_amount DECIMAL(8,2) DEFAULT 0.00,
    shipping_cost DECIMAL(8,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_order_date (order_date),
    INDEX idx_status (status),
    INDEX idx_customer_id (customer_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id) ON DELETE SET NULL
);

-- 6. ORDER DETAILS TABLE
CREATE TABLE order_details (
    detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    discount DECIMAL(5,2) DEFAULT 0.00,
    line_total DECIMAL(12,2) GENERATED ALWAYS AS ((quantity * unit_price) - discount) STORED,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_order_id (order_id),
    INDEX idx_product_id (product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- 7. INTERACTIONS TABLE
CREATE TABLE interactions (
    interaction_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    rep_id INT NOT NULL,
    interaction_type ENUM('Phone Call', 'Email', 'Meeting', 'Demo', 'Support', 'Follow-up') NOT NULL,
    date_time DATETIME NOT NULL,
    duration INT,
    notes TEXT,
    outcome ENUM('Successful', 'No Answer', 'Rescheduled', 'Interested', 'Not Interested', 'Closed Won', 'Closed Lost'),
    follow_up_date DATE,
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_customer_id (customer_id),
    INDEX idx_rep_id (rep_id),
    INDEX idx_interaction_type (interaction_type),
    INDEX idx_date_time (date_time),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id) ON DELETE CASCADE
);

-- 8. TASKS TABLE
CREATE TABLE tasks (
    task_id INT AUTO_INCREMENT PRIMARY KEY,
    assigned_to INT NOT NULL,
    customer_id INT,
    task_type ENUM('Follow-up', 'Demo', 'Proposal', 'Contract', 'Support', 'Research') NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    priority ENUM('Low', 'Medium', 'High', 'Urgent') DEFAULT 'Medium',
    status ENUM('Open', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Open',
    created_date DATE NOT NULL,
    due_date DATE,
    completed_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_assigned_to (assigned_to),
    INDEX idx_status (status),
    INDEX idx_due_date (due_date),
    INDEX idx_priority (priority),
    FOREIGN KEY (assigned_to) REFERENCES sales_representatives(rep_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- 9. OPPORTUNITIES TABLE
CREATE TABLE opportunities (
    opportunity_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    rep_id INT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    value DECIMAL(12,2) NOT NULL,
    probability INT DEFAULT 50,
    stage ENUM('Prospecting', 'Qualification', 'Proposal', 'Negotiation', 'Closed Won', 'Closed Lost') DEFAULT 'Prospecting',
    expected_close_date DATE,
    created_date DATE NOT NULL,
    source ENUM('Inbound', 'Outbound', 'Referral', 'Partner') DEFAULT 'Inbound',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_customer_id (customer_id),
    INDEX idx_rep_id (rep_id),
    INDEX idx_stage (stage),
    INDEX idx_expected_close_date (expected_close_date),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE,
    FOREIGN KEY (rep_id) REFERENCES sales_representatives(rep_id) ON DELETE CASCADE
);

-- 10. CAMPAIGNS TABLE
CREATE TABLE campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    type ENUM('Email', 'Social Media', 'Print', 'Digital', 'Event', 'Direct Mail') NOT NULL,
    status ENUM('Planning', 'Active', 'Paused', 'Completed', 'Cancelled') DEFAULT 'Planning',
    start_date DATE NOT NULL,
    end_date DATE,
    budget DECIMAL(12,2) DEFAULT 0.00,
    target_audience TEXT,
    created_by INT NOT NULL,
    roi DECIMAL(8,4),
    leads_generated INT DEFAULT 0,
    conversions INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_type (type),
    INDEX idx_status (status),
    INDEX idx_start_date (start_date),
    FOREIGN KEY (created_by) REFERENCES sales_representatives(rep_id) ON DELETE CASCADE
);

-- 11. CAMPAIGN LEADS TABLE
CREATE TABLE campaign_leads (
    campaign_id INT NOT NULL,
    lead_id INT NOT NULL,
    response_date DATE,
    response_type ENUM('Clicked', 'Opened', 'Replied', 'Converted', 'Unsubscribed'),
    PRIMARY KEY (campaign_id, lead_id),
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    FOREIGN KEY (lead_id) REFERENCES leads(lead_id) ON DELETE CASCADE
);


-- STEP 2: SAMPLE DATA INSERTION
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE campaign_leads;
TRUNCATE TABLE campaigns;
TRUNCATE TABLE opportunities;
TRUNCATE TABLE tasks;
TRUNCATE TABLE interactions;
TRUNCATE TABLE order_details;
TRUNCATE TABLE orders;
TRUNCATE TABLE products;
TRUNCATE TABLE leads;
TRUNCATE TABLE customers;
TRUNCATE TABLE sales_representatives;
SET FOREIGN_KEY_CHECKS = 1;

-- INSERT SALES REPRESENTATIVES
INSERT INTO sales_representatives (first_name, last_name, email, phone, hire_date, territory, quota, commission_rate, manager_id, status) VALUES
('John', 'Smith', 'john.smith@company.com', '(555) 001-1001', '2022-01-15', 'North East', 1500000, 0.0600, NULL, 'Active'),
('Sarah', 'Johnson', 'sarah.johnson@company.com', '(555) 002-1002', '2022-02-20', 'South East', 1400000, 0.0580, 1, 'Active'),
('Michael', 'Brown', 'michael.brown@company.com', '(555) 003-1003', '2022-03-10', 'Mid West', 1300000, 0.0550, 1, 'Active'),
('Lisa', 'Davis', 'lisa.davis@company.com', '(555) 004-1004', '2022-04-05', 'West Coast', 1600000, 0.0620, 2, 'Active'),
('David', 'Wilson', 'david.wilson@company.com', '(555) 005-1005', '2022-05-12', 'Central', 1350000, 0.0540, 2, 'Active'),
('Emily', 'Garcia', 'emily.garcia@company.com', '(555) 006-1006', '2022-06-18', 'International', 1800000, 0.0700, 1, 'Active'),
('James', 'Rodriguez', 'james.rodriguez@company.com', '(555) 007-1007', '2022-07-22', 'North East', 1250000, 0.0520, 3, 'Active'),
('Amanda', 'Martinez', 'amanda.martinez@company.com', '(555) 008-1008', '2022-08-30', 'South East', 1300000, 0.0530, 3, 'Active'),
('Christopher', 'Anderson', 'christopher.anderson@company.com', '(555) 009-1009', '2022-09-15', 'Mid West', 1200000, 0.0510, 4, 'Active'),
('Jessica', 'Taylor', 'jessica.taylor@company.com', '(555) 010-1010', '2022-10-20', 'West Coast', 1450000, 0.0590, 4, 'Active'),
('Matthew', 'Thomas', 'matthew.thomas@company.com', '(555) 011-1011', '2023-01-08', 'Central', 1100000, 0.0480, 5, 'Active'),
('Ashley', 'Jackson', 'ashley.jackson@company.com', '(555) 012-1012', '2023-02-14', 'International', 1700000, 0.0680, 5, 'Active'),
('Daniel', 'White', 'daniel.white@company.com', '(555) 013-1013', '2023-03-25', 'North East', 1150000, 0.0470, 1, 'Active'),
('Stephanie', 'Harris', 'stephanie.harris@company.com', '(555) 014-1014', '2023-04-30', 'South East', 1250000, 0.0520, 2, 'Active'),
('Anthony', 'Clark', 'anthony.clark@company.com', '(555) 015-1015', '2023-05-16', 'Mid West', 1180000, 0.0490, 3, 'Active'),
('Melissa', 'Lewis', 'melissa.lewis@company.com', '(555) 016-1016', '2023-06-22', 'West Coast', 1320000, 0.0560, 4, 'Active'),
('Mark', 'Lee', 'mark.lee@company.com', '(555) 017-1017', '2023-07-18', 'Central', 1080000, 0.0450, 5, 'Active'),
('Nicole', 'Walker', 'nicole.walker@company.com', '(555) 018-1018', '2023-08-25', 'International', 1600000, 0.0650, 1, 'Active'),
('Donald', 'Hall', 'donald.hall@company.com', '(555) 019-1019', '2023-09-12', 'North East', 1120000, 0.0460, 2, 'Active'),
('Kimberly', 'Allen', 'kimberly.allen@company.com', '(555) 020-1020', '2023-10-08', 'South East', 1200000, 0.0500, 3, 'Active'),
('Steven', 'Young', 'steven.young@company.com', '(555) 021-1021', '2023-11-15', 'Mid West', 1090000, 0.0440, 4, 'Active'),
('Donna', 'King', 'donna.king@company.com', '(555) 022-1022', '2023-12-20', 'West Coast', 1280000, 0.0540, 5, 'Active'),
('Paul', 'Wright', 'paul.wright@company.com', '(555) 023-1023', '2024-01-10', 'Central', 1050000, 0.0420, 1, 'Active'),
('Carol', 'Lopez', 'carol.lopez@company.com', '(555) 024-1024', '2024-02-18', 'International', 1550000, 0.0630, 2, 'Active'),
('Andrew', 'Hill', 'andrew.hill@company.com', '(555) 025-1025', '2024-03-05', 'North East', 1000000, 0.0400, 3, 'Active');

-- INSERT CUSTOMERS
INSERT INTO customers (first_name, last_name, email, phone, company, industry, website, address, city, state, country, postal_code, customer_type, registration_date, status, credit_limit, assigned_rep_id) VALUES
('Robert', 'Johnson', 'robert.johnson@techcorp.com', '(555) 101-2001', 'TechCorp Inc', 'Technology', 'www.techcorp.com', '123 Main St', 'New York', 'NY', 'USA', '10001', 'Enterprise', '2023-01-15', 'Active', 100000, 1),
('Jennifer', 'Williams', 'jennifer.williams@globalsolutions.com', '(555) 102-2002', 'Global Solutions LLC', 'Technology', 'www.globalsolutions.com', '456 Oak Ave', 'Los Angeles', 'CA', 'USA', '90001', 'Business', '2023-02-20', 'Active', 75000, 2),
('Michael', 'Brown', 'michael.brown@innovatesys.com', '(555) 103-2003', 'Innovate Systems', 'Healthcare', 'www.innovatesys.com', '789 Pine Rd', 'Chicago', 'IL', 'USA', '60601', 'Enterprise', '2023-03-10', 'Active', 120000, 3),
('Linda', 'Davis', 'linda.davis@digitaldynamics.com', '(555) 104-2004', 'Digital Dynamics', 'Finance', 'www.digitaldynamics.com', '321 Elm St', 'Houston', 'TX', 'USA', '77001', 'Business', '2023-04-05', 'Active', 80000, 4),
('William', 'Miller', 'william.miller@futuretech.com', '(555) 105-2005', 'Future Tech', 'Technology', 'www.futuretech.com', '654 Maple Ave', 'Phoenix', 'AZ', 'USA', '85001', 'Business', '2023-05-12', 'Active', 60000, 5),
('Elizabeth', 'Wilson', 'elizabeth.wilson@quantumind.com', '(555) 106-2006', 'Quantum Industries', 'Manufacturing', 'www.quantumind.com', '987 Cedar Rd', 'Philadelphia', 'PA', 'USA', '19101', 'Enterprise', '2023-06-18', 'Active', 150000, 6),
('James', 'Moore', 'james.moore@alphaent.com', '(555) 107-2007', 'Alpha Enterprises', 'Retail', 'www.alphaent.com', '147 Birch St', 'San Antonio', 'TX', 'USA', '78201', 'Business', '2023-07-22', 'Active', 45000, 7),
('Maria', 'Taylor', 'maria.taylor@betacorp.com', '(555) 108-2008', 'Beta Corp', 'Education', 'www.betacorp.com', '258 Spruce Ave', 'San Diego', 'CA', 'USA', '92101', 'Business', '2023-08-30', 'Active', 55000, 8),
('Robert', 'Anderson', 'robert.anderson@gammasol.com', '(555) 109-2009', 'Gamma Solutions', 'Technology', 'www.gammasol.com', '369 Willow Rd', 'Dallas', 'TX', 'USA', '75201', 'Enterprise', '2023-09-15', 'Active', 95000, 9),
('Patricia', 'Thomas', 'patricia.thomas@deltasys.com', '(555) 110-2010', 'Delta Systems', 'Healthcare', 'www.deltasys.com', '741 Poplar St', 'San Jose', 'CA', 'USA', '95101', 'Business', '2023-10-20', 'Active', 70000, 10),
('Charles', 'Jackson', 'charles.jackson@omegatech.com', '(555) 111-2011', 'Omega Technologies', 'Technology', 'www.omegatech.com', '852 Hickory Ave', 'Austin', 'TX', 'USA', '73301', 'Enterprise', '2023-11-08', 'Active', 110000, 11),
('Barbara', 'White', 'barbara.white@nexusinno.com', '(555) 112-2012', 'Nexus Innovations', 'Finance', 'www.nexusinno.com', '963 Walnut Rd', 'Jacksonville', 'FL', 'USA', '32201', 'Business', '2023-12-14', 'Active', 65000, 12),
('Joseph', 'Harris', 'joseph.harris@vertexsol.com', '(555) 113-2013', 'Vertex Solutions', 'Manufacturing', 'www.vertexsol.com', '159 Chestnut St', 'Fort Worth', 'TX', 'USA', '76101', 'Enterprise', '2024-01-25', 'Active', 130000, 13),
('Susan', 'Martin', 'susan.martin@primeind.com', '(555) 114-2014', 'Prime Industries', 'Real Estate', 'www.primeind.com', '357 Ash Ave', 'Columbus', 'OH', 'USA', '43201', 'Business', '2024-02-16', 'Active', 50000, 14),
('Thomas', 'Thompson', 'thomas.thompson@apexcorp.com', '(555) 115-2015', 'Apex Corp', 'Technology', 'www.apexcorp.com', '486 Beech Rd', 'Charlotte', 'NC', 'USA', '28201', 'Business', '2024-03-22', 'Active', 75000, 15),
('Margaret', 'Garcia', 'margaret.garcia@zenithsys.com', '(555) 116-2016', 'Zenith Systems', 'Healthcare', 'www.zenithsys.com', '753 Dogwood St', 'Seattle', 'WA', 'USA', '98101', 'Enterprise', '2024-04-18', 'Prospect', 100000, 16),
('Christopher', 'Martinez', 'christopher.martinez@pinnacletech.com', '(555) 117-2017', 'Pinnacle Tech', 'Technology', 'www.pinnacletech.com', '864 Sycamore Ave', 'Denver', 'CO', 'USA', '80201', 'Business', '2024-05-25', 'Prospect', 60000, 17),
('Sarah', 'Robinson', 'sarah.robinson@summitcorp.com', '(555) 118-2018', 'Summit Corp', 'Finance', 'www.summitcorp.com', '975 Magnolia Rd', 'Washington', 'DC', 'USA', '20001', 'Enterprise', '2024-06-12', 'Active', 140000, 18),
('Daniel', 'Clark', 'daniel.clark@crestind.com', '(555) 119-2019', 'Crest Industries', 'Manufacturing', 'www.crestind.com', '186 Redwood St', 'Boston', 'MA', 'USA', '02101', 'Business', '2024-07-08', 'Active', 85000, 19),
('Nancy', 'Rodriguez', 'nancy.rodriguez@peaksol.com', '(555) 120-2020', 'Peak Solutions', 'Retail', 'www.peaksol.com', '297 Cypress Ave', 'Las Vegas', 'NV', 'USA', '89101', 'Business', '2024-08-15', 'Prospect', 40000, 20),
('Kenneth', 'Lewis', 'kenneth.lewis@horizontech.com', '(555) 121-2021', 'Horizon Tech', 'Technology', 'www.horizontech.com', '408 Juniper Rd', 'Detroit', 'MI', 'USA', '48201', 'Enterprise', '2024-01-20', 'Active', 105000, 21),
('Lisa', 'Lee', 'lisa.lee@vanguardcorp.com', '(555) 122-2022', 'Vanguard Corp', 'Healthcare', 'www.vanguardcorp.com', '519 Fir St', 'Memphis', 'TN', 'USA', '38101', 'Business', '2024-02-28', 'Active', 70000, 22),
('Steven', 'Walker', 'steven.walker@pioneersys.com', '(555) 123-2023', 'Pioneer Systems', 'Education', 'www.pioneersys.com', '630 Laurel Ave', 'Portland', 'OR', 'USA', '97201', 'Business', '2024-03-14', 'Active', 55000, 23),
('Betty', 'Hall', 'betty.hall@catalysttech.com', '(555) 124-2024', 'Catalyst Tech', 'Technology', 'www.catalysttech.com', '741 Willow Rd', 'Oklahoma City', 'OK', 'USA', '73101', 'Enterprise', '2024-04-09', 'Prospect', 90000, 24),
('Edward', 'Allen', 'edward.allen@advancecorp.com', '(555) 125-2025', 'Advance Corp', 'Finance', 'www.advancecorp.com', '852 Palm St', 'Louisville', 'KY', 'USA', '40201', 'Business', '2024-05-05', 'Active', 65000, 25),
('Helen', 'Young', 'helen.young@evolutionind.com', '(555) 126-2026', 'Evolution Industries', 'Manufacturing', 'www.evolutionind.com', '963 Oak Ave', 'Milwaukee', 'WI', 'USA', '53201', 'Enterprise', '2024-06-20', 'Active', 115000, 1),
('Jason', 'Hernandez', 'jason.hernandez@transformtech.com', '(555) 127-2027', 'Transform Tech', 'Technology', 'www.transformtech.com', '174 Pine St', 'Albuquerque', 'NM', 'USA', '87101', 'Business', '2024-07-16', 'Prospect', 75000, 2),
('Dorothy', 'King', 'dorothy.king@elevatecorp.com', '(555) 128-2028', 'Elevate Corp', 'Healthcare', 'www.elevatecorp.com', '285 Elm Rd', 'Tucson', 'AZ', 'USA', '85701', 'Business', '2024-08-12', 'Active', 60000, 3),
('Mark', 'Wright', 'mark.wright@innovativesys.com', '(555) 129-2029', 'Innovative Systems', 'Technology', 'www.innovativesys.com', '396 Maple St', 'Fresno', 'CA', 'USA', '93701', 'Enterprise', '2024-01-30', 'Active', 120000, 4),
('Sharon', 'Lopez', 'sharon.lopez@progresstech.com', '(555) 130-2030', 'Progress Tech', 'Finance', 'www.progresstech.com', '507 Cedar Ave', 'Sacramento', 'CA', 'USA', '94201', 'Business', '2024-02-25', 'Prospect', 70000, 5),
('Donald', 'Hill', 'donald.hill@dynamicind.com', '(555) 131-2031', 'Dynamic Industries', 'Manufacturing', 'www.dynamicind.com', '618 Birch Rd', 'Long Beach', 'CA', 'USA', '90801', 'Enterprise', '2024-03-18', 'Active', 95000, 6),
('Michelle', 'Scott', 'michelle.scott@velocitycorp.com', '(555) 132-2032', 'Velocity Corp', 'Retail', 'www.velocitycorp.com', '729 Spruce St', 'Kansas City', 'MO', 'USA', '64101', 'Business', '2024-04-22', 'Active', 50000, 7),
('Paul', 'Green', 'paul.green@momentumtech.com', '(555) 133-2033', 'Momentum Tech', 'Technology', 'www.momentumtech.com', '840 Willow Ave', 'Mesa', 'AZ', 'USA', '85201', 'Business', '2024-05-28', 'Prospect', 65000, 8),
('Sandra', 'Adams', 'sandra.adams@acceleratesys.com', '(555) 134-2034', 'Accelerate Systems', 'Healthcare', 'www.acceleratesys.com', '951 Poplar Rd', 'Virginia Beach', 'VA', 'USA', '23451', 'Enterprise', '2024-06-14', 'Active', 105000, 9),
('Ryan', 'Baker', 'ryan.baker@thriveind.com', '(555) 135-2035', 'Thrive Industries', 'Education', 'www.thriveind.com', '162 Hickory St', 'Atlanta', 'GA', 'USA', '30301', 'Business', '2024-07-10', 'Active', 45000, 10),
('Kimberly', 'Gonzalez', 'kimberly.gonzalez@flourishcorp.com', '(555) 136-2036', 'Flourish Corp', 'Technology', 'www.flourishcorp.com', '273 Walnut Ave', 'Colorado Springs', 'CO', 'USA', '80901', 'Enterprise', '2024-08-06', 'Prospect', 85000, 11),
('Timothy', 'Nelson', 'timothy.nelson@prospertech.com', '(555) 137-2037', 'Prosper Tech', 'Finance', 'www.prospertech.com', '384 Chestnut Rd', 'Omaha', 'NE', 'USA', '68101', 'Business', '2024-01-12', 'Active', 75000, 12),
('Angela', 'Carter', 'angela.carter@excelsys.com', '(555) 138-2038', 'Excel Systems', 'Manufacturing', 'www.excelsys.com', '495 Ash St', 'Raleigh', 'NC', 'USA', '27601', 'Enterprise', '2024-02-08', 'Active', 110000, 13),
('Harold', 'Mitchell', 'harold.mitchell@triumphind.com', '(555) 139-2039', 'Triumph Industries', 'Real Estate', 'www.triumphind.com', '606 Beech Ave', 'Miami', 'FL', 'USA', '33101', 'Business', '2024-03-06', 'Prospect', 55000, 14),
('Brenda', 'Perez', 'brenda.perez@victorycorp.com', '(555) 140-2040', 'Victory Corp', 'Technology', 'www.victorycorp.com', '717 Dogwood Rd', 'Oakland', 'CA', 'USA', '94601', 'Business', '2024-04-02', 'Active', 80000, 15),
('Arthur', 'Roberts', 'arthur.roberts@conquestech.com', '(555) 141-2041', 'Conquest Tech', 'Healthcare', 'www.conquestech.com', '828 Sycamore St', 'Minneapolis', 'MN', 'USA', '55401', 'Enterprise', '2024-04-28', 'Active', 125000, 16),
('Pamela', 'Turner', 'pamela.turner@mastercorp.com', '(555) 142-2042', 'Master Corp', 'Technology', 'www.mastercorp.com', '939 Magnolia Ave', 'Tulsa', 'OK', 'USA', '74101', 'Business', '2024-05-24', 'Prospect', 70000, 17),
('Henry', 'Phillips', 'henry.phillips@championsys.com', '(555) 143-2043', 'Champion Systems', 'Finance', 'www.championsys.com', '150 Redwood Rd', 'Cleveland', 'OH', 'USA', '44101', 'Enterprise', '2024-06-19', 'Active', 100000, 18),
('Deborah', 'Campbell', 'deborah.campbell@leaderind.com', '(555) 144-2044', 'Leader Industries', 'Manufacturing', 'www.leaderind.com', '261 Cypress St', 'Wichita', 'KS', 'USA', '67201', 'Business', '2024-07-15', 'Active', 60000, 19),
('Walter', 'Parker', 'walter.parker@elitetech.com', '(555) 145-2045', 'Elite Tech', 'Technology', 'www.elitetech.com', '372 Juniper Ave', 'Arlington', 'TX', 'USA', '76001', 'Enterprise', '2024-08-11', 'Prospect', 90000, 20),
('Carol', 'Evans', 'carol.evans@supremecorp.com', '(555) 146-2046', 'Supreme Corp', 'Retail', 'www.supremecorp.com', '483 Fir Rd', 'New Orleans', 'LA', 'USA', '70112', 'Business', '2024-01-07', 'Active', 45000, 21),
('Ralph', 'Edwards', 'ralph.edwards@premiumsys.com', '(555) 147-2047', 'Premium Systems', 'Healthcare', 'www.premiumsys.com', '594 Laurel St', 'Bakersfield', 'CA', 'USA', '93301', 'Business', '2024-02-03', 'Active', 65000, 22),
('Janet', 'Collins', 'janet.collins@optimalind.com', '(555) 148-2048', 'Optimal Industries', 'Education', 'www.optimalind.com', '705 Willow Ave', 'Tampa', 'FL', 'USA', '33601', 'Business', '2024-02-29', 'Prospect', 50000, 23),
('Eugene', 'Stewart', 'eugene.stewart@ultimatetech.com', '(555) 149-2049', 'Ultimate Tech', 'Technology', 'www.ultimatetech.com', '816 Palm Rd', 'Aurora', 'CO', 'USA', '80010', 'Enterprise', '2024-03-26', 'Active', 115000, 24),
('Catherine', 'Sanchez', 'catherine.sanchez@maximumcorp.com', '(555) 150-2050', 'Maximum Corp', 'Finance', 'www.maximumcorp.com', '927 Oak St', 'Anaheim', 'CA', 'USA', '92801', 'Business', '2024-04-21', 'Active', 75000, 25);

-- INSERT LEADS
INSERT INTO leads (first_name, last_name, email, phone, company, source, status, score, assigned_to, created_date, estimated_value, notes) VALUES
('Jennifer', 'Wilson', 'j.wilson@prospectcorp.com', '(555) 201-3001', 'Prospect Corp', 'Website', 'New', 85, 1, '2024-06-15', 45000, 'Interested in CRM solution'),
('Michael', 'Chen', 'm.chen@futuretech.com', '(555) 202-3002', 'Future Tech Ltd', 'Cold Call', 'Contacted', 75, 2, '2024-06-20', 32000, 'Needs follow-up demo'),
('Sarah', 'Davis', 's.davis@innovateplus.com', '(555) 203-3003', 'Innovate Plus', 'Referral', 'Qualified', 90, 3, '2024-06-25', 67000, 'Ready for proposal'),
('Robert', 'Martinez', 'r.martinez@alphaind.com', '(555) 204-3004', 'Alpha Industries', 'Social Media', 'New', 65, 4, '2024-07-01', 28000, 'Initial contact made'),
('Lisa', 'Anderson', 'l.anderson@betasys.com', '(555) 205-3005', 'Beta Systems', 'Email Campaign', 'Contacted', 80, 5, '2024-07-10', 52000, 'Scheduled for next week'),
('David', 'Thompson', 'd.thompson@gammatech.com', '(555) 206-3006', 'Gamma Tech', 'Trade Show', 'Qualified', 95, 1, '2024-07-15', 89000, 'High priority prospect'),
('Emily', 'Garcia', 'e.garcia@deltacorp.com', '(555) 207-3007', 'Delta Corp', 'Website', 'New', 70, 2, '2024-07-20', 41000, 'Downloaded whitepaper'),
('James', 'Rodriguez', 'j.rodriguez@omegasol.com', '(555) 208-3008', 'Omega Solutions', 'Referral', 'Converted', 100, 3, '2024-06-05', 125000, 'Converted to customer'),
('Amanda', 'Lee', 'a.lee@nexusinc.com', '(555) 209-3009', 'Nexus Inc', 'Cold Call', 'Disqualified', 30, 4, '2024-07-25', 0, 'Not a good fit'),
('Christopher', 'White', 'c.white@vertextech.com', '(555) 210-3010', 'Vertex Tech', 'Advertisement', 'Qualified', 88, 5, '2024-08-01', 73000, 'Ready for demo'),
('Jessica', 'Brown', 'j.brown@pinnaclesys.com', '(555) 211-3011', 'Pinnacle Systems', 'Website', 'New', 78, 6, '2024-08-05', 56000, 'Requested information'),
('Matthew', 'Miller', 'm.miller@summittech.com', '(555) 212-3012', 'Summit Tech', 'Email Campaign', 'Contacted', 82, 7, '2024-08-10', 48000, 'Follow-up scheduled'),
('Ashley', 'Wilson', 'a.wilson@crestcorp.com', '(555) 213-3013', 'Crest Corp', 'Social Media', 'Qualified', 87, 8, '2024-08-15', 64000, 'Demo completed'),
('Daniel', 'Moore', 'd.moore@peakind.com', '(555) 214-3014', 'Peak Industries', 'Referral', 'New', 72, 9, '2024-08-20', 39000, 'Referral from client'),
('Stephanie', 'Taylor', 's.taylor@horizonsys.com', '(555) 215-3015', 'Horizon Systems', 'Trade Show', 'Contacted', 85, 10, '2024-08-25', 57000, 'Met at conference'),
('Anthony', 'Anderson', 'a.anderson@vanguardtech.com', '(555) 216-3016', 'Vanguard Tech', 'Website', 'Qualified', 91, 11, '2024-06-30', 71000, 'High interest level'),
('Melissa', 'Thomas', 'm.thomas@pioneercorp.com', '(555) 217-3017', 'Pioneer Corp', 'Cold Call', 'New', 68, 12, '2024-07-05', 35000, 'Initial outreach'),
('Mark', 'Jackson', 'm.jackson@catalystsys.com', '(555) 218-3018', 'Catalyst Systems', 'Email Campaign', 'Contacted', 79, 13, '2024-07-12', 46000, 'Opened campaign'),
('Nicole', 'White', 'n.white@advancetech.com', '(555) 219-3019', 'Advance Tech', 'Advertisement', 'Qualified', 84, 14, '2024-07-18', 58000, 'Clicked ad, requested demo'),
('Donald', 'Harris', 'd.harris@evolutioncorp.com', '(555) 220-3020', 'Evolution Corp', 'Referral', 'New', 76, 15, '2024-07-22', 42000, 'Partner referral'),
('Kimberly', 'Martin', 'k.martin@transformsys.com', '(555) 221-3021', 'Transform Systems', 'Website', 'Contacted', 81, 16, '2024-07-28', 53000, 'Downloaded case study'),
('Steven', 'Thompson', 's.thompson@elevatetech.com', '(555) 222-3022', 'Elevate Tech', 'Social Media', 'Qualified', 86, 17, '2024-08-02', 61000, 'LinkedIn connection'),
('Donna', 'Garcia', 'd.garcia@innovcorp.com', '(555) 223-3023', 'Innovation Corp', 'Trade Show', 'New', 73, 18, '2024-08-08', 37000, 'Trade show contact'),
('Paul', 'Martinez', 'p.martinez@progressind.com', '(555) 224-3024', 'Progress Industries', 'Email Campaign', 'Contacted', 77, 19, '2024-08-12', 44000, 'Email response'),
('Carol', 'Rodriguez', 'c.rodriguez@dynamicsys.com', '(555) 225-3025', 'Dynamic Systems', 'Website', 'Qualified', 89, 20, '2024-08-18', 66000, 'Form submission'),
('Andrew', 'Lewis', 'a.lewis@velocitytech.com', '(555) 226-3026', 'Velocity Tech', 'Cold Call', 'New', 69, 21, '2024-08-22', 33000, 'Cold call response'),
('Ruth', 'Lee', 'r.lee@momentumcorp.com', '(555) 227-3027', 'Momentum Corp', 'Referral', 'Contacted', 83, 22, '2024-08-26', 54000, 'Customer referral'),
('Sharon', 'Walker', 's.walker@accelerateind.com', '(555) 228-3028', 'Accelerate Industries', 'Advertisement', 'Qualified', 92, 23, '2024-06-28', 75000, 'High-value prospect'),
('Jason', 'Hall', 'j.hall@thrivesys.com', '(555) 229-3029', 'Thrive Systems', 'Website', 'New', 74, 24, '2024-07-03', 38000, 'Website inquiry'),
('Betty', 'Allen', 'b.allen@flourishtech.com', '(555) 230-3030', 'Flourish Tech', 'Trade Show', 'Contacted', 80, 25, '2024-07-08', 47000, 'Conference follow-up');

-- INSERT PRODUCTS
INSERT INTO products (product_name, category, description, unit_price, cost_price, stock_quantity, reorder_level, status) VALUES
('CRM Professional License', 'Software', 'Professional CRM software license with advanced features', 4999.99, 2500.00, 50, 10, 'Active'),
('CRM Enterprise License', 'Software', 'Enterprise-grade CRM with unlimited users', 12999.99, 6500.00, 25, 5, 'Active'),
('Mobile CRM App', 'Software', 'Mobile application for field sales teams', 1999.99, 1000.00, 75, 15, 'Active'),
('Data Migration Service', 'Services', 'Complete data migration from legacy systems', 7500.00, 4000.00, 20, 5, 'Active'),
('Custom Integration', 'Services', 'Custom API integration with existing systems', 5500.00, 3000.00, 30, 8, 'Active'),
('CRM Training - Basic', 'Training', '2-day basic CRM training program', 2500.00, 1200.00, 40, 10, 'Active'),
('CRM Training - Advanced', 'Training', '3-day advanced CRM administration training', 3500.00, 1800.00, 35, 8, 'Active'),
('Technical Support Package', 'Support', '24/7 technical support for 1 year', 3000.00, 1500.00, 100, 20, 'Active'),
('Premium Support Package', 'Support', 'Priority support with dedicated account manager', 6000.00, 3000.00, 50, 10, 'Active'),
('CRM Consulting - Strategy', 'Consulting', 'Strategic CRM implementation consulting', 8000.00, 4500.00, 15, 3, 'Active'),
('CRM Consulting - Technical', 'Consulting', 'Technical architecture and setup consulting', 6500.00, 3500.00, 20, 5, 'Active'),
('Reporting Dashboard Add-on', 'Software', 'Advanced reporting and analytics dashboard', 2999.99, 1500.00, 60, 12, 'Active'),
('Workflow Automation Tool', 'Software', 'Automated workflow and process management', 3999.99, 2000.00, 45, 10, 'Active'),
('CRM Hardware Bundle', 'Hardware', 'Complete hardware setup for CRM deployment', 15000.00, 9000.00, 10, 2, 'Active'),
('Legacy System Connector', 'Software', 'Connector for legacy ERP and database systems', 4500.00, 2500.00, 25, 5, 'Active');

-- INSERT ORDERS
INSERT INTO orders (customer_id, rep_id, order_date, expected_delivery, status, total_amount, discount, tax_amount, shipping_cost) VALUES
(1, 1, '2024-01-15', '2024-02-15', 'Delivered', 17999.97, 500.00, 1440.00, 200.00),
(2, 2, '2024-01-20', '2024-02-20', 'Delivered', 15499.97, 500.00, 1200.00, 180.00),
(3, 3, '2024-01-25', '2024-02-25', 'Delivered', 20499.96, 1000.00, 1560.00, 250.00),
(4, 4, '2024-02-01', '2024-03-01', 'Delivered', 12999.99, 0.00, 1040.00, 160.00),
(5, 5, '2024-02-10', '2024-03-10', 'Delivered', 9999.97, 300.00, 775.00, 140.00),
(6, 6, '2024-02-15', '2024-03-15', 'Delivered', 28999.94, 1500.00, 2200.00, 300.00),
(7, 7, '2024-02-20', '2024-03-20', 'Delivered', 8499.98, 400.00, 648.00, 120.00),
(8, 8, '2024-02-25', '2024-03-25', 'Delivered', 6999.99, 200.00, 544.00, 100.00),
(9, 9, '2024-03-01', '2024-04-01', 'Delivered', 25999.95, 1200.00, 1984.00, 280.00),
(10, 10, '2024-03-05', '2024-04-05', 'Delivered', 14999.98, 600.00, 1152.00, 180.00),
(11, 11, '2024-03-10', '2024-04-10', 'Delivered', 18499.97, 800.00, 1416.00, 220.00),
(12, 12, '2024-03-15', '2024-04-15', 'Delivered', 11499.99, 300.00, 892.00, 150.00),
(13, 13, '2024-03-20', '2024-04-20', 'Delivered', 23999.96, 1000.00, 1840.00, 260.00),
(14, 14, '2024-03-25', '2024-04-25', 'Delivered', 7999.99, 200.00, 624.00, 110.00),
(15, 15, '2024-04-01', '2024-05-01', 'Delivered', 16999.98, 700.00, 1304.00, 190.00),
(16, 16, '2024-04-05', '2024-05-05', 'Delivered', 13999.99, 400.00, 1088.00, 170.00),
(17, 17, '2024-04-10', '2024-05-10', 'Delivered', 21999.97, 900.00, 1688.00, 240.00),
(18, 18, '2024-04-15', '2024-05-15', 'Delivered', 9999.99, 250.00, 780.00, 130.00),
(19, 19, '2024-04-20', '2024-05-20', 'Delivered', 26999.95, 1300.00, 2072.00, 290.00),
(20, 20, '2024-04-25', '2024-05-25', 'Delivered', 12499.99, 350.00, 970.00, 160.00),
(21, 21, '2024-05-01', '2024-06-01', 'Shipped', 19999.97, 750.00, 1540.00, 210.00),
(22, 22, '2024-05-05', '2024-06-05', 'Shipped', 8999.99, 300.00, 704.00, 125.00),
(23, 23, '2024-05-10', '2024-06-10', 'Shipped', 15999.98, 550.00, 1236.00, 185.00),
(24, 24, '2024-05-15', '2024-06-15', 'Processing', 22999.96, 1100.00, 1752.00, 255.00),
(25, 25, '2024-05-20', '2024-06-20', 'Processing', 11999.99, 400.00, 928.00, 155.00),
(26, 1, '2024-05-25', '2024-06-25', 'Processing', 17999.98, 650.00, 1386.00, 195.00),
(27, 2, '2024-06-01', '2024-07-01', 'Processing', 14499.99, 500.00, 1124.00, 175.00),
(28, 3, '2024-06-05', '2024-07-05', 'Pending', 24999.95, 1250.00, 1900.00, 275.00),
(29, 4, '2024-06-10', '2024-07-10', 'Pending', 10999.99, 350.00, 858.00, 145.00),
(30, 5, '2024-06-15', '2024-07-15', 'Pending', 18999.97, 700.00, 1463.00, 205.00),
(31, 6, '2024-06-20', '2024-07-20', 'Pending', 13499.99, 450.00, 1050.00, 165.00),
(32, 7, '2024-06-25', '2024-07-25', 'Pending', 20999.96, 850.00, 1617.00, 235.00),
(33, 8, '2024-07-01', '2024-08-01', 'Pending', 9499.99, 275.00, 741.00, 135.00),
(34, 9, '2024-07-05', '2024-08-05', 'Pending', 25999.94, 1400.00, 1968.00, 285.00),
(35, 10, '2024-07-10', '2024-08-10', 'Pending', 12999.99, 425.00, 1014.00, 160.00),
(36, 11, '2024-07-15', '2024-08-15', 'Pending', 16999.97, 600.00, 1311.00, 190.00),
(37, 12, '2024-07-20', '2024-08-20', 'Pending', 14999.99, 525.00, 1162.00, 175.00),
(38, 13, '2024-07-25', '2024-08-25', 'Pending', 23499.96, 1150.00, 1802.00, 265.00),
(39, 14, '2024-08-01', '2024-09-01', 'Pending', 11499.99, 375.00, 897.00, 150.00),
(40, 15, '2024-08-05', '2024-09-05', 'Pending', 19999.98, 750.00, 1540.00, 210.00);


INSERT INTO order_details (order_id, product_id, quantity, unit_price, discount) VALUES
(1, 1, 2, 4999.99, 200.00), (1, 6, 3, 2500.00, 100.00), (1, 8, 1, 3000.00, 50.00),
(2, 2, 1, 12999.99, 500.00), (2, 9, 1, 6000.00, 0.00),
(3, 2, 1, 12999.99, 500.00), (3, 4, 1, 7500.00, 300.00), (3, 10, 1, 8000.00, 200.00),
(4, 2, 1, 12999.99, 0.00),
(5, 1, 1, 4999.99, 150.00), (5, 6, 2, 2500.00, 100.00), (5, 8, 1, 3000.00, 50.00),
(6, 2, 2, 12999.99, 800.00), (6, 4, 1, 7500.00, 300.00), (6, 11, 1, 6500.00, 200.00), (6, 9, 1, 6000.00, 200.00),
(7, 1, 1, 4999.99, 200.00), (7, 5, 1, 5500.00, 200.00),
(8, 3, 3, 1999.99, 100.00), (8, 7, 2, 3500.00, 100.00),
(9, 2, 1, 12999.99, 600.00), (9, 4, 1, 7500.00, 300.00), (9, 10, 1, 8000.00, 300.00),
(10, 1, 2, 4999.99, 300.00), (10, 12, 1, 2999.99, 100.00), (10, 8, 1, 3000.00, 100.00),
(11, 2, 1, 12999.99, 400.00), (11, 13, 1, 3999.99, 200.00), (11, 9, 1, 6000.00, 200.00),
(12, 1, 1, 4999.99, 150.00), (12, 5, 1, 5500.00, 150.00), (12, 8, 1, 3000.00, 0.00),
(13, 2, 1, 12999.99, 500.00), (13, 14, 1, 15000.00, 500.00),
(14, 1, 1, 4999.99, 100.00), (14, 6, 1, 2500.00, 100.00), (14, 8, 1, 3000.00, 0.00),
(15, 2, 1, 12999.99, 400.00), (15, 15, 1, 4500.00, 200.00), (15, 9, 1, 6000.00, 100.00),
(16, 1, 2, 4999.99, 200.00), (16, 12, 1, 2999.99, 100.00), (16, 8, 2, 3000.00, 100.00),
(17, 2, 1, 12999.99, 500.00), (17, 4, 1, 7500.00, 200.00), (17, 10, 1, 8000.00, 200.00),
(18, 1, 1, 4999.99, 125.00), (18, 6, 2, 2500.00, 75.00), (18, 8, 1, 3000.00, 50.00),
(19, 2, 2, 12999.99, 650.00), (19, 9, 1, 6000.00, 150.00),
(20, 1, 1, 4999.99, 175.00), (20, 5, 1, 5500.00, 175.00), (20, 8, 1, 3000.00, 0.00),
(21, 2, 1, 12999.99, 400.00), (21, 11, 1, 6500.00, 200.00), (21, 9, 1, 6000.00, 150.00),
(22, 1, 1, 4999.99, 150.00), (22, 7, 1, 3500.00, 150.00), (22, 8, 1, 3000.00, 0.00),
(23, 2, 1, 12999.99, 350.00), (23, 15, 1, 4500.00, 200.00),
(24, 2, 1, 12999.99, 550.00), (24, 14, 1, 15000.00, 550.00),
(25, 1, 1, 4999.99, 200.00), (25, 6, 2, 2500.00, 100.00), (25, 8, 1, 3000.00, 100.00),
(26, 2, 1, 12999.99, 350.00), (26, 13, 1, 3999.99, 150.00), (26, 9, 1, 6000.00, 150.00),
(27, 1, 2, 4999.99, 250.00), (27, 12, 1, 2999.99, 100.00), (27, 8, 1, 3000.00, 150.00),
(28, 2, 1, 12999.99, 625.00), (28, 4, 1, 7500.00, 300.00), (28, 10, 1, 8000.00, 325.00),
(29, 1, 1, 4999.99, 175.00), (29, 6, 2, 2500.00, 100.00), (29, 8, 1, 3000.00, 75.00),
(30, 2, 1, 12999.99, 400.00), (30, 11, 1, 6500.00, 150.00), (30, 9, 1, 6000.00, 150.00),
(31, 1, 1, 4999.99, 225.00), (31, 5, 1, 5500.00, 225.00),
(32, 2, 1, 12999.99, 425.00), (32, 15, 1, 4500.00, 200.00), (32, 9, 1, 6000.00, 225.00),
(33, 1, 1, 4999.99, 137.50), (33, 7, 1, 3500.00, 137.50),
(34, 2, 2, 12999.99, 700.00), (34, 9, 1, 6000.00, 200.00),
(35, 1, 2, 4999.99, 212.50), (35, 8, 1, 3000.00, 212.50),
(36, 2, 1, 12999.99, 300.00), (36, 13, 1, 3999.99, 150.00), (36, 8, 1, 3000.00, 150.00),
(37, 1, 2, 4999.99, 262.50), (37, 12, 1, 2999.99, 125.00), (37, 8, 1, 3000.00, 137.50),
(38, 2, 1, 12999.99, 575.00), (38, 14, 1, 15000.00, 575.00),
(39, 1, 1, 4999.99, 187.50), (39, 6, 2, 2500.00, 93.75), (39, 8, 1, 3000.00, 93.75),
(40, 2, 1, 12999.99, 375.00), (40, 11, 1, 6500.00, 187.50), (40, 9, 1, 6000.00, 187.50);

-- INSERT INTERACTIONS
INSERT INTO interactions (customer_id, rep_id, interaction_type, date_time, duration, notes, outcome, follow_up_date, priority) VALUES
(1, 1, 'Phone Call', '2024-01-10 09:30:00', 45, 'Initial needs assessment call', 'Interested', '2024-01-17', 'High'),
(1, 1, 'Email', '2024-01-12 14:15:00', 5, 'Sent product brochure and pricing', 'Successful', '2024-01-19', 'Medium'),
(1, 1, 'Meeting', '2024-01-14 10:00:00', 90, 'In-person demo at client office', 'Successful', NULL, 'High'),
(2, 2, 'Phone Call', '2024-01-18 11:30:00', 30, 'Follow-up on proposal submission', 'Interested', '2024-01-25', 'Medium'),
(2, 2, 'Demo', '2024-01-19 15:00:00', 120, 'Online product demonstration', 'Successful', '2024-01-26', 'High'),
(2, 2, 'Email', '2024-01-20 16:45:00', 10, 'Contract terms negotiation', 'Interested', NULL, 'High'),
(3, 3, 'Meeting', '2024-01-22 14:00:00', 75, 'Executive stakeholder presentation', 'Closed Won', NULL, 'Urgent'),
(3, 3, 'Phone Call', '2024-01-24 09:15:00', 25, 'Technical requirements discussion', 'Successful', '2024-01-31', 'Medium'),
(3, 3, 'Support', '2024-01-25 13:30:00', 60, 'Implementation planning session', 'Successful', NULL, 'High'),
(4, 4, 'Phone Call', '2024-01-28 10:45:00', 20, 'Budget approval status check', 'Interested', '2024-02-04', 'Medium'),
(4, 4, 'Follow-up', '2024-01-30 15:20:00', 15, 'Checking on decision timeline', 'Rescheduled', '2024-02-06', 'Low'),
(4, 4, 'Email', '2024-02-01 11:00:00', 8, 'Sent updated proposal', 'Successful', NULL, 'High'),
(5, 5, 'Demo', '2024-02-05 14:30:00', 105, 'Comprehensive product walkthrough', 'Interested', '2024-02-12', 'High'),
(5, 5, 'Phone Call', '2024-02-08 16:00:00', 35, 'Addressing technical concerns', 'Successful', '2024-02-15', 'Medium'),
(5, 5, 'Meeting', '2024-02-10 10:30:00', 60, 'Final negotiations meeting', 'Closed Won', NULL, 'Urgent'),
(6, 6, 'Phone Call', '2024-02-12 09:00:00', 40, 'Initial contact and qualification', 'Interested', '2024-02-19', 'High'),
(6, 6, 'Demo', '2024-02-14 15:30:00', 120, 'Enterprise features demonstration', 'Successful', '2024-02-21', 'High'),
(6, 6, 'Meeting', '2024-02-15 11:00:00', 90, 'Stakeholder alignment meeting', 'Closed Won', NULL, 'Urgent'),
(7, 7, 'Email', '2024-02-18 08:45:00', 12, 'Cold outreach with case studies', 'Interested', '2024-02-25', 'Medium'),
(7, 7, 'Phone Call', '2024-02-20 14:15:00', 28, 'Discovery call on current process', 'Successful', '2024-02-27', 'High'),
(7, 7, 'Demo', '2024-02-22 16:00:00', 95, 'Tailored demo for retail industry', 'Interested', NULL, 'High'),
(8, 8, 'Phone Call', '2024-02-25 10:20:00', 32, 'Educational sector needs analysis', 'Interested', '2024-03-03', 'Medium'),
(8, 8, 'Meeting', '2024-02-27 13:45:00', 70, 'On-site consultation', 'Successful', '2024-03-05', 'High'),
(8, 8, 'Follow-up', '2024-02-28 09:30:00', 18, 'Post-demo feedback collection', 'Interested', NULL, 'Medium'),
(9, 9, 'Demo', '2024-03-01 15:15:00', 110, 'Advanced analytics showcase', 'Successful', '2024-03-08', 'High'),
(9, 9, 'Phone Call', '2024-03-03 11:40:00', 42, 'Integration requirements discussion', 'Interested', '2024-03-10', 'High'),
(9, 9, 'Meeting', '2024-03-05 14:20:00', 85, 'Contract finalization meeting', 'Closed Won', NULL, 'Urgent'),
(10, 10, 'Email', '2024-03-08 12:30:00', 8, 'Healthcare compliance documentation', 'Successful', '2024-03-15', 'Medium'),
(10, 10, 'Phone Call', '2024-03-10 16:45:00', 38, 'Security and compliance discussion', 'Interested', '2024-03-17', 'High'),
(10, 10, 'Demo', '2024-03-12 10:00:00', 125, 'HIPAA-compliant features demo', 'Successful', NULL, 'High'),
(11, 11, 'Phone Call', '2024-03-15 09:20:00', 26, 'Technology upgrade consultation', 'Interested', '2024-03-22', 'Medium'),
(11, 11, 'Meeting', '2024-03-18 14:30:00', 95, 'Executive presentation', 'Successful', '2024-03-25', 'High'),
(11, 11, 'Follow-up', '2024-03-20 11:15:00', 22, 'Implementation timeline planning', 'Interested', NULL, 'High'),
(12, 12, 'Email', '2024-03-22 13:50:00', 15, 'Financial services case study', 'Interested', '2024-03-29', 'Medium'),
(12, 12, 'Demo', '2024-03-25 15:45:00', 105, 'Risk management features demo', 'Successful', '2024-04-01', 'High'),
(12, 12, 'Phone Call', '2024-03-27 10:30:00', 35, 'Pricing and terms negotiation', 'Interested', NULL, 'High'),
(13, 13, 'Meeting', '2024-03-30 11:00:00', 80, 'Manufacturing process integration', 'Successful', '2024-04-06', 'High'),
(13, 13, 'Support', '2024-04-02 14:15:00', 55, 'Technical architecture review', 'Successful', '2024-04-09', 'Medium'),
(13, 13, 'Phone Call', '2024-04-04 16:20:00', 30, 'Final approval confirmation', 'Closed Won', NULL, 'Urgent'),
(14, 14, 'Phone Call', '2024-04-08 09:45:00', 24, 'Real estate market analysis', 'Interested', '2024-04-15', 'Low'),
(14, 14, 'Email', '2024-04-10 12:20:00', 10, 'Property management features info', 'Successful', '2024-04-17', 'Medium'),
(14, 14, 'Demo', '2024-04-12 15:30:00', 85, 'CRM for real estate demo', 'Interested', NULL, 'Medium'),
(15, 15, 'Demo', '2024-04-15 14:00:00', 100, 'Technology startup consultation', 'Successful', '2024-04-22', 'High'),
(15, 15, 'Meeting', '2024-04-18 10:45:00', 70, 'Scalability planning session', 'Interested', '2024-04-25', 'High'),
(15, 15, 'Phone Call', '2024-04-20 16:10:00', 28, 'Investment timeline discussion', 'Interested', NULL, 'Medium'),
(16, 16, 'Phone Call', '2024-04-22 11:30:00', 33, 'Healthcare system integration', 'Interested', '2024-04-29', 'High'),
(16, 16, 'Email', '2024-04-24 13:40:00', 12, 'Patient data management info', 'Successful', '2024-05-01', 'Medium'),
(16, 16, 'Meeting', '2024-04-26 09:15:00', 95, 'Compliance and security meeting', 'Successful', NULL, 'High'),
(17, 17, 'Demo', '2024-04-28 15:20:00', 115, 'Advanced technology features', 'Interested', '2024-05-05', 'High'),
(17, 17, 'Phone Call', '2024-05-01 14:25:00', 29, 'Custom development discussion', 'Successful', '2024-05-08', 'Medium'),
(17, 17, 'Follow-up', '2024-05-03 10:50:00', 20, 'Project scope clarification', 'Interested', NULL, 'Medium'),
(18, 18, 'Meeting', '2024-05-06 13:30:00', 85, 'Financial compliance review', 'Successful', '2024-05-13', 'High'),
(18, 18, 'Support', '2024-05-08 11:45:00', 65, 'Implementation planning', 'Successful', '2024-05-15', 'High'),
(18, 18, 'Phone Call', '2024-05-10 15:35:00', 25, 'Final contract terms', 'Closed Won', NULL, 'Urgent'),
(19, 19, 'Phone Call', '2024-05-12 10:15:00', 31, 'Manufacturing efficiency goals', 'Interested', '2024-05-19', 'Medium'),
(19, 19, 'Demo', '2024-05-15 14:45:00', 120, 'Production workflow demo', 'Successful', '2024-05-22', 'High'),
(19, 19, 'Email', '2024-05-17 16:20:00', 8, 'ROI calculations and projections', 'Interested', NULL, 'High'),
(20, 20, 'Email', '2024-05-20 09:30:00', 10, 'Retail industry trends report', 'Interested', '2024-05-27', 'Low'),
(20, 20, 'Phone Call', '2024-05-22 13:15:00', 27, 'Customer experience improvement', 'Successful', '2024-05-29', 'Medium'),
(20, 20, 'Demo', '2024-05-24 15:50:00', 90, 'Retail CRM features demonstration', 'Interested', NULL, 'Medium');

-- INSERT TASKS
INSERT INTO tasks (assigned_to, customer_id, task_type, title, description, priority, status, created_date, due_date, completed_date) VALUES
(1, 1, 'Follow-up', 'Follow up on CRM demo', 'Schedule follow-up call after initial demo', 'High', 'Completed', '2024-01-10', '2024-01-17', '2024-01-16'),
(1, 2, 'Proposal', 'Prepare enterprise proposal', 'Create comprehensive proposal for enterprise CRM solution', 'Urgent', 'Completed', '2024-01-15', '2024-01-22', '2024-01-21'),
(1, 16, 'Research', 'Healthcare compliance research', 'Research HIPAA and healthcare compliance requirements', 'Medium', 'In Progress', '2024-04-22', '2024-05-01', NULL),
(2, 3, 'Demo', 'Schedule product demo', 'Coordinate online demo with technical team', 'Medium', 'Completed', '2024-01-20', '2024-01-27', '2024-01-26'),
(2, 4, 'Research', 'Research client requirements', 'Analyze client current system and integration needs', 'Medium', 'Completed', '2024-01-25', '2024-02-01', '2024-01-31'),
(2, 17, 'Follow-up', 'Technology integration follow-up', 'Follow up on custom development requirements', 'Medium', 'Open', '2024-05-01', '2024-05-08', NULL),
(3, 5, 'Contract', 'Review contract terms', 'Legal review of proposed contract modifications', 'High', 'Completed', '2024-02-01', '2024-02-08', '2024-02-07'),
(3, 6, 'Support', 'Implementation kickoff', 'Schedule implementation kickoff meeting', 'Urgent', 'Completed', '2024-02-10', '2024-02-17', '2024-02-15'),
(3, 18, 'Contract', 'Financial services contract', 'Finalize contract terms for financial client', 'High', 'In Progress', '2024-05-10', '2024-05-17', NULL),
(4, 7, 'Follow-up', 'Retail industry follow-up', 'Follow up on retail-specific requirements', 'Medium', 'Open', '2024-02-20', '2024-02-27', NULL),
(4, 8, 'Demo', 'Educational demo preparation', 'Prepare demo focused on educational sector needs', 'High', 'Completed', '2024-02-25', '2024-03-03', '2024-03-02'),
(4, 19, 'Proposal', 'Manufacturing proposal', 'Create proposal for manufacturing efficiency solution', 'High', 'Open', '2024-05-15', '2024-05-22', NULL),
(5, 9, 'Research', 'Analytics requirements analysis', 'Deep dive into client analytics and reporting needs', 'High', 'Completed', '2024-03-01', '2024-03-08', '2024-03-06'),
(5, 10, 'Proposal', 'Healthcare compliance proposal', 'Develop HIPAA-compliant CRM proposal', 'High', 'Completed', '2024-03-08', '2024-03-15', '2024-03-14'),
(5, 20, 'Demo', 'Retail CRM demo', 'Schedule and conduct retail-focused CRM demo', 'Medium', 'Open', '2024-05-22', '2024-05-29', NULL),
(6, 11, 'Follow-up', 'Technology upgrade consultation', 'Follow up on technology modernization needs', 'Medium', 'In Progress', '2024-03-15', '2024-03-22', NULL),
(6, 12, 'Research', 'Financial services compliance', 'Research regulatory requirements for financial sector', 'Medium', 'Completed', '2024-03-22', '2024-03-29', '2024-03-28'),
(7, 13, 'Support', 'Manufacturing implementation support', 'Provide technical support for manufacturing integration', 'High', 'In Progress', '2024-03-30', '2024-04-06', NULL),
(7, 14, 'Follow-up', 'Real estate market follow-up', 'Follow up on property management CRM needs', 'Low', 'Open', '2024-04-08', '2024-04-15', NULL),
(8, 15, 'Demo', 'Startup scalability demo', 'Demonstrate scalable CRM solutions for growth', 'High', 'Open', '2024-04-18', '2024-04-25', NULL),
(8, 21, 'Research', 'Enterprise tech requirements', 'Analyze enterprise technology infrastructure needs', 'Medium', 'Open', '2024-05-01', '2024-05-08', NULL),
(9, 22, 'Follow-up', 'Healthcare system integration', 'Follow up on integration with existing healthcare systems', 'High', 'Open', '2024-05-05', '2024-05-12', NULL),
(9, 23, 'Demo', 'Educational system demo', 'Prepare demo for educational institution', 'Medium', 'Open', '2024-05-10', '2024-05-17', NULL),
(10, 24, 'Proposal', 'Technology startup proposal', 'Create growth-oriented CRM proposal', 'High', 'Open', '2024-05-15', '2024-05-22', NULL),
(10, 25, 'Research', 'Financial compliance research', 'Research compliance requirements for financial services', 'Medium', 'Open', '2024-05-20', '2024-05-27', NULL),
(11, 26, 'Follow-up', 'Manufacturing follow-up', 'Follow up on production integration requirements', 'Medium', 'Open', '2024-05-25', '2024-06-01', NULL),
(12, 27, 'Demo', 'Healthcare technology demo', 'Demonstrate healthcare-specific CRM features', 'High', 'Open', '2024-06-01', '2024-06-08', NULL),
(13, 28, 'Proposal', 'Technology modernization proposal', 'Create proposal for legacy system upgrade', 'High', 'Open', '2024-06-05', '2024-06-12', NULL),
(14, 29, 'Research', 'Finance industry trends', 'Research latest trends in financial services CRM', 'Low', 'Open', '2024-06-10', '2024-06-17', NULL),
(15, 30, 'Support', 'Implementation support', 'Provide ongoing implementation support', 'Medium', 'Open', '2024-06-15', '2024-06-22', NULL),
(16, 31, 'Follow-up', 'Manufacturing efficiency follow-up', 'Check on efficiency improvement goals', 'Medium', 'Open', '2024-06-20', '2024-06-27', NULL),
(17, 32, 'Demo', 'Retail automation demo', 'Demonstrate retail process automation', 'Medium', 'Open', '2024-06-25', '2024-07-02', NULL),
(18, 33, 'Contract', 'Technology services contract', 'Finalize contract for technology services', 'High', 'Open', '2024-07-01', '2024-07-08', NULL),
(19, 34, 'Research', 'Healthcare innovation research', 'Research innovative healthcare CRM solutions', 'Medium', 'Open', '2024-07-05', '2024-07-12', NULL),
(20, 35, 'Proposal', 'Educational institution proposal', 'Create comprehensive proposal for education sector', 'High', 'Open', '2024-07-10', '2024-07-17', NULL),
(21, 36, 'Follow-up', 'Technology upgrade follow-up', 'Follow up on system modernization progress', 'Medium', 'Open', '2024-07-15', '2024-07-22', NULL),
(22, 37, 'Demo', 'Financial services demo', 'Demonstrate compliance and security features', 'High', 'Open', '2024-07-20', '2024-07-27', NULL),
(23, 38, 'Support', 'Manufacturing support', 'Provide technical support for production systems', 'Medium', 'Open', '2024-07-25', '2024-08-01', NULL),
(24, 39, 'Research', 'Real estate technology trends', 'Research latest real estate technology trends', 'Low', 'Open', '2024-08-01', '2024-08-08', NULL),
(25, 40, 'Proposal', 'Technology innovation proposal', 'Create proposal for innovative technology solutions', 'High', 'Open', '2024-08-05', '2024-08-12', NULL),
(1, NULL, 'Research', 'Market analysis Q3', 'Conduct comprehensive market analysis for Q3 planning', 'Medium', 'Open', '2024-07-01', '2024-07-15', NULL),
(2, NULL, 'Follow-up', 'Lead nurturing campaign', 'Follow up with warm leads from recent campaigns', 'Medium', 'In Progress', '2024-07-05', '2024-07-12', NULL),
(3, NULL, 'Support', 'Team training preparation', 'Prepare training materials for new CRM features', 'Low', 'Open', '2024-07-10', '2024-07-20', NULL),
(4, NULL, 'Research', 'Competitive analysis', 'Analyze competitor offerings and pricing strategies', 'Medium', 'Open', '2024-07-15', '2024-07-25', NULL),
(5, NULL, 'Proposal', 'Territory expansion proposal', 'Create proposal for expanding into new territories', 'High', 'Open', '2024-07-20', '2024-08-01', NULL);

-- INSERT OPPORTUNITIES
INSERT INTO opportunities (customer_id, rep_id, title, description, value, probability, stage, expected_close_date, created_date, source) VALUES
(1, 1, 'CRM Software Implementation', 'Complete CRM solution for sales team automation', 125000, 95, 'Closed Won', '2024-01-31', '2024-01-10', 'Inbound'),
(2, 2, 'Enterprise CRM Upgrade', 'Upgrade existing CRM to enterprise version', 89000, 90, 'Closed Won', '2024-02-15', '2024-01-15', 'Outbound'),
(3, 3, 'Multi-location CRM Deployment', 'CRM deployment across 5 office locations', 215000, 95, 'Closed Won', '2024-02-28', '2024-01-20', 'Referral'),
(4, 4, 'Integration Services Package', 'Custom integrations with existing ERP system', 95000, 85, 'Closed Won', '2024-03-15', '2024-01-25', 'Partner'),
(5, 5, 'Training and Support Contract', 'Comprehensive training and 2-year support', 75000, 90, 'Closed Won', '2024-03-01', '2024-02-01', 'Inbound'),
(6, 6, 'CRM Modernization Project', 'Complete legacy system replacement', 340000, 95, 'Closed Won', '2024-03-20', '2024-01-05', 'Outbound'),
(7, 7, 'Sales Analytics Platform', 'Advanced analytics and reporting platform', 68000, 75, 'Negotiation', '2024-09-30', '2024-02-10', 'Inbound'),
(8, 8, 'Mobile CRM Solution', 'Mobile CRM app for field sales teams', 52000, 80, 'Proposal', '2024-10-15', '2024-02-15', 'Referral'),
(9, 9, 'Customer Service CRM', 'CRM solution for customer service department', 185000, 90, 'Closed Won', '2024-04-10', '2024-02-20', 'Partner'),
(10, 10, 'Marketing Automation Add-on', 'Marketing automation integration package', 95000, 85, 'Closed Won', '2024-04-25', '2024-02-25', 'Inbound'),
(11, 11, 'Technology Infrastructure Upgrade', 'Complete technology modernization', 165000, 85, 'Closed Won', '2024-05-15', '2024-03-10', 'Outbound'),
(12, 12, 'Financial Services CRM', 'Compliance-ready CRM for financial sector', 125000, 80, 'Negotiation', '2024-10-30', '2024-03-15', 'Inbound'),
(13, 13, 'Manufacturing Process Integration', 'CRM integration with manufacturing systems', 275000, 90, 'Closed Won', '2024-05-30', '2024-03-20', 'Referral'),
(14, 14, 'Real Estate CRM Platform', 'Property management and client tracking system', 85000, 65, 'Proposal', '2024-11-15', '2024-03-25', 'Partner'),
(15, 15, 'Startup Growth Platform', 'Scalable CRM for rapid business growth', 145000, 75, 'Qualification', '2024-12-01', '2024-04-01', 'Inbound'),
(16, 16, 'Healthcare CRM Implementation', 'HIPAA-compliant healthcare CRM solution', 195000, 70, 'Qualification', '2024-11-30', '2024-04-05', 'Outbound'),
(17, 17, 'Custom Technology Solution', 'Tailored CRM with custom development', 225000, 60, 'Prospecting', '2024-12-15', '2024-04-10', 'Referral'),
(18, 18, 'Financial Compliance Platform', 'Regulatory compliance and reporting system', 285000, 85, 'Closed Won', '2024-06-20', '2024-04-15', 'Partner'),
(19, 19, 'Manufacturing Efficiency Suite', 'Production optimization and tracking system', 165000, 70, 'Proposal', '2024-11-20', '2024-04-20', 'Inbound'),
(20, 20, 'Retail Customer Experience Platform', 'Customer journey and experience management', 115000, 55, 'Prospecting', '2024-12-30', '2024-04-25', 'Outbound'),
(21, 21, 'Enterprise Technology Modernization', 'Legacy system replacement and modernization', 385000, 80, 'Negotiation', '2024-10-15', '2024-05-01', 'Referral'),
(22, 22, 'Healthcare System Integration', 'Integration with existing healthcare infrastructure', 235000, 75, 'Qualification', '2024-11-10', '2024-05-05', 'Partner'),
(23, 23, 'Educational Institution CRM', 'Student and faculty management system', 145000, 65, 'Proposal', '2024-12-10', '2024-05-10', 'Inbound'),
(24, 24, 'Technology Startup Platform', 'Growth-oriented CRM for tech startup', 95000, 70, 'Qualification', '2024-11-25', '2024-05-15', 'Outbound'),
(25, 25, 'Financial Services Automation', 'Process automation for financial operations', 205000, 60, 'Prospecting', '2025-01-15', '2024-05-20', 'Referral'),
(26, 1, 'Manufacturing Digital Transformation', 'Complete digital transformation initiative', 450000, 85, 'Negotiation', '2024-10-31', '2024-05-25', 'Partner'),
(27, 2, 'Healthcare Innovation Platform', 'Next-generation healthcare management system', 315000, 70, 'Qualification', '2024-12-20', '2024-06-01', 'Inbound'),
(28, 3, 'Technology Modernization Suite', 'Comprehensive technology upgrade package', 275000, 75, 'Proposal', '2024-11-30', '2024-06-05', 'Outbound'),
(29, 4, 'Financial Regulatory Platform', 'Compliance and regulatory reporting system', 185000, 65, 'Prospecting', '2025-01-31', '2024-06-10', 'Referral'),
(30, 5, 'Educational Technology Initiative', 'Digital learning and management platform', 225000, 60, 'Prospecting', '2025-02-15', '2024-06-15', 'Partner'),
(31, 6, 'Manufacturing Excellence Program', 'Operational excellence and quality management', 195000, 80, 'Proposal', '2024-12-05', '2024-06-20', 'Inbound'),
(32, 7, 'Retail Digital Platform', 'Omnichannel retail management system', 165000, 55, 'Prospecting', '2025-01-20', '2024-06-25', 'Outbound'),
(33, 8, 'Technology Services Platform', 'Service delivery and customer management', 145000, 70, 'Qualification', '2024-12-15', '2024-07-01', 'Referral'),
(34, 9, 'Healthcare Quality Initiative', 'Quality management and patient care system', 285000, 75, 'Proposal', '2024-11-15', '2024-07-05', 'Partner'),
(35, 10, 'Educational Excellence Program', 'Student success and institutional management', 205000, 65, 'Qualification', '2025-01-10', '2024-07-10', 'Inbound');

-- INSERT CAMPAIGNS
INSERT INTO campaigns (name, type, status, start_date, end_date, budget, target_audience, created_by, roi, leads_generated, conversions) VALUES
('Q1 CRM Webinar Series', 'Digital', 'Completed', '2024-01-01', '2024-03-31', 15000, 'SMB Technology Companies', 1, 2.5, 45, 8),
('Enterprise Email Campaign', 'Email', 'Completed', '2024-02-01', '2024-04-30', 8000, 'Enterprise IT Directors', 2, 1.8, 32, 5),
('Tech Expo 2024 Trade Show', 'Event', 'Completed', '2024-01-15', '2024-01-17', 25000, 'Technology Professionals', 3, 3.2, 78, 12),
('LinkedIn Lead Generation', 'Social Media', 'Completed', '2024-02-15', '2024-05-15', 12000, 'Sales Managers and Directors', 4, 2.1, 56, 9),
('Healthcare Digital Summit', 'Event', 'Completed', '2024-03-01', '2024-03-03', 20000, 'Healthcare IT Professionals', 5, 2.8, 67, 11),
('Spring Direct Mail Campaign', 'Direct Mail', 'Completed', '2024-03-15', '2024-04-30', 18000, 'Manufacturing Companies', 6, 1.9, 34, 6),
('Google Ads Retargeting', 'Digital', 'Completed', '2024-04-01', '2024-06-30', 10000, 'Website Visitors', 7, 2.2, 41, 7),
('Partner Referral Program', 'Event', 'Active', '2024-01-01', '2024-12-31', 50000, 'Technology Partners', 8, 2.6, 89, 18),
('Content Marketing Series', 'Digital', 'Active', '2024-05-01', '2024-08-31', 22000, 'Sales Professionals', 9, 2.4, 73, 14),
('Summer CRM Demo Days', 'Event', 'Active', '2024-06-01', '2024-08-31', 15000, 'Local Business Owners', 10, NULL, 28, 5),
('Financial Services Webinar', 'Digital', 'Active', '2024-06-15', '2024-09-15', 12000, 'Financial Services Professionals', 11, NULL, 19, 3),
('Manufacturing Automation Fair', 'Event', 'Planning', '2024-09-01', '2024-09-03', 30000, 'Manufacturing Engineers', 12, NULL, 0, 0),
('Holiday Promotion Campaign', 'Email', 'Planning', '2024-11-15', '2024-12-31', 8000, 'Existing Customers', 13, NULL, 0, 0),
('New Year Growth Initiative', 'Digital', 'Planning', '2025-01-01', '2025-03-31', 25000, 'Growing Businesses', 14, NULL, 0, 0),
('Q4 Enterprise Outreach', 'Email', 'Active', '2024-07-01', '2024-12-31', 18000, 'Enterprise Decision Makers', 15, NULL, 12, 2);

-- INSERT CAMPAIGN LEADS
INSERT INTO campaign_leads (campaign_id, lead_id, response_date, response_type) VALUES
(1, 1, '2024-01-16', 'Clicked'), (1, 2, '2024-01-18', 'Opened'), (1, 3, '2024-01-22', 'Converted'),
(1, 6, '2024-02-05', 'Clicked'), (1, 11, '2024-02-12', 'Opened'),
(2, 4, '2024-02-05', 'Replied'), (2, 5, '2024-02-08', 'Clicked'), (2, 12, '2024-03-15', 'Opened'), (2, 16, '2024-03-22', 'Clicked'),
(3, 6, '2024-01-16', 'Converted'), (3, 7, '2024-01-16', 'Clicked'), (3, 15, '2024-01-17', 'Clicked'), (3, 20, '2024-01-17', 'Opened'),
(4, 8, '2024-02-20', 'Opened'), (4, 9, '2024-02-22', 'Unsubscribed'), (4, 13, '2024-03-10', 'Clicked'), (4, 17, '2024-03-18', 'Replied'),
(5, 10, '2024-03-02', 'Converted'), (5, 14, '2024-03-03', 'Clicked'), (5, 18, '2024-03-03', 'Opened'),
(6, 19, '2024-03-20', 'Replied'), (6, 21, '2024-03-25', 'Clicked'), (6, 24, '2024-04-02', 'Opened'),
(7, 22, '2024-04-15', 'Clicked'), (7, 23, '2024-04-20', 'Clicked'), (7, 25, '2024-05-01', 'Converted'),
(8, 26, '2024-05-10', 'Converted'), (8, 27, '2024-05-15', 'Replied'), (8, 28, '2024-06-01', 'Clicked'),
(9, 29, '2024-05-20', 'Opened'), (9, 30, '2024-06-05', 'Clicked'),
(10, 1, '2024-06-10', 'Opened'), (10, 4, '2024-06-15', 'Clicked');

-- UPDATE DATA 
UPDATE leads SET status = 'Converted', converted_date = '2024-02-01', converted_customer_id = 26 WHERE lead_id = 8;
UPDATE leads SET status = 'Converted', converted_date = '2024-01-28', converted_customer_id = 27 WHERE lead_id = 3;
UPDATE leads SET status = 'Converted', converted_date = '2024-03-05', converted_customer_id = 28 WHERE lead_id = 10;
UPDATE leads SET status = 'Converted', converted_date = '2024-05-15', converted_customer_id = 29 WHERE lead_id = 25;
UPDATE leads SET status = 'Converted', converted_date = '2024-05-22', converted_customer_id = 30 WHERE lead_id = 26;

UPDATE opportunities SET stage = 'Closed Won', probability = 100 WHERE opportunity_id IN (1, 2, 3, 4, 5, 6, 9, 10, 11, 13, 18);
UPDATE opportunities SET stage = 'Closed Lost', probability = 0 WHERE opportunity_id IN (7, 15, 20);

UPDATE tasks SET status = 'Completed', completed_date = '2024-01-16' WHERE task_id = 1;
UPDATE tasks SET status = 'Completed', completed_date = '2024-01-21' WHERE task_id = 2;
UPDATE tasks SET status = 'Completed', completed_date = '2024-01-26' WHERE task_id = 4;
UPDATE tasks SET status = 'Completed', completed_date = '2024-01-31' WHERE task_id = 5;
UPDATE tasks SET status = 'Completed', completed_date = '2024-02-07' WHERE task_id = 7;
UPDATE tasks SET status = 'Completed', completed_date = '2024-02-15' WHERE task_id = 8;
UPDATE tasks SET status = 'Completed', completed_date = '2024-03-02' WHERE task_id = 10;
UPDATE tasks SET status = 'Completed', completed_date = '2024-03-06' WHERE task_id = 13;
UPDATE tasks SET status = 'Completed', completed_date = '2024-03-14' WHERE task_id = 14;
UPDATE tasks SET status = 'Completed', completed_date = '2024-03-28' WHERE task_id = 17;

UPDATE customers SET last_contact_date = '2024-08-15' WHERE customer_id IN (1, 2, 3, 4, 5);
UPDATE customers SET last_contact_date = '2024-08-10' WHERE customer_id IN (6, 7, 8, 9, 10);
UPDATE customers SET last_contact_date = '2024-08-05' WHERE customer_id IN (11, 12, 13, 14, 15);
UPDATE customers SET last_contact_date = '2024-07-30' WHERE customer_id IN (16, 17, 18, 19, 20);
UPDATE customers SET last_contact_date = '2024-07-25' WHERE customer_id IN (21, 22, 23, 24, 25);

UPDATE campaigns SET roi = 2.5, leads_generated = 45, conversions = 8 WHERE campaign_id = 1;
UPDATE campaigns SET roi = 1.8, leads_generated = 32, conversions = 5 WHERE campaign_id = 2;
UPDATE campaigns SET roi = 3.2, leads_generated = 78, conversions = 12 WHERE campaign_id = 3;
UPDATE campaigns SET roi = 2.1, leads_generated = 56, conversions = 9 WHERE campaign_id = 4;
UPDATE campaigns SET roi = 2.8, leads_generated = 67, conversions = 11 WHERE campaign_id = 5;
UPDATE campaigns SET roi = 1.9, leads_generated = 34, conversions = 6 WHERE campaign_id = 6;
UPDATE campaigns SET roi = 2.2, leads_generated = 41, conversions = 7 WHERE campaign_id = 7;
SELECT * FROM campaigns;

UPDATE products SET stock_quantity = stock_quantity - 15 WHERE product_id IN (1, 2, 3);
UPDATE products SET stock_quantity = stock_quantity - 8 WHERE product_id IN (4, 5, 6);
UPDATE products SET stock_quantity = stock_quantity - 12 WHERE product_id IN (8, 9, 10);


SELECT * FROM customers LIMIT 10;
SELECT customer_id, first_name, last_name, company, industry, status FROM customers WHERE status = 'Active';
SELECT company, industry, credit_limit FROM customers WHERE status = 'Active' ORDER BY credit_limit DESC;
SELECT DISTINCT industry FROM customers;
SELECT first_name, last_name, email, company FROM customers WHERE company LIKE '%Tech%' OR company LIKE '%System%';

-- FILTERING AND CONDITIONAL OPERATORS
SELECT customer_id, company, credit_limit FROM customers WHERE credit_limit >= 75000;
SELECT * FROM customers WHERE industry IN ('Technology', 'Healthcare', 'Finance');
SELECT customer_id, company, registration_date FROM customers WHERE registration_date BETWEEN '2024-01-01' AND '2024-06-30';
SELECT customer_id, company, last_contact_date FROM customers WHERE last_contact_date IS NULL;

-- BASIC INSERT, UPDATE
INSERT INTO customers (first_name, last_name, email, company, industry, registration_date, status, assigned_rep_id)
VALUES ('Alex', 'Thompson', 'alex.thompson@newtech.com', 'NewTech Solutions', 'Technology', CURDATE(), 'Prospect', 1);

UPDATE customers SET status = 'Active', last_contact_date = CURDATE() WHERE email = 'alex.thompson@newtech.com';
UPDATE customers SET last_contact_date = CURDATE() WHERE status = 'Active' AND last_contact_date IS NULL;
SELECT * FROM customers;

-- AGGREGATE FUNCTIONS
SELECT COUNT(*) as total_customers FROM customers;
SELECT COUNT(DISTINCT industry) as unique_industries FROM customers;
SELECT COUNT(*) as total_orders, SUM(total_amount) as total_revenue, AVG(total_amount) as avg_order_value, MIN(total_amount) as min_order, MAX(total_amount) as max_order FROM orders;

-- GROUP BY CLAUSES
SELECT industry, COUNT(*) as customer_count FROM customers GROUP BY industry ORDER BY customer_count DESC;
SELECT industry, status, COUNT(*) as count FROM customers GROUP BY industry, status ORDER BY industry, status;
SELECT sr.territory, COUNT(c.customer_id) as customer_count, AVG(c.credit_limit) as avg_credit_limit FROM sales_representatives sr LEFT JOIN customers c ON sr.rep_id = c.assigned_rep_id WHERE sr.status = 'Active' GROUP BY sr.territory;

-- HAVING CLAUSE
SELECT industry, COUNT(*) as customer_count FROM customers GROUP BY industry HAVING COUNT(*) >= 5 ORDER BY customer_count DESC;
SELECT sr.territory, COUNT(o.order_id) as total_orders, SUM(o.total_amount) as total_revenue FROM sales_representatives sr JOIN orders o ON sr.rep_id = o.rep_id GROUP BY sr.territory HAVING SUM(o.total_amount) > 100000 ORDER BY total_revenue DESC;

-- INNER JOINS
SELECT c.customer_id, c.company, sr.first_name as rep_first_name, sr.last_name as rep_last_name, sr.territory FROM customers c INNER JOIN sales_representatives sr ON c.assigned_rep_id = sr.rep_id WHERE c.status = 'Active';

SELECT o.order_id, c.company as customer_company, sr.first_name as rep_name, o.order_date, o.total_amount, o.status FROM orders o INNER JOIN customers c ON o.customer_id = c.customer_id INNER JOIN sales_representatives sr ON o.rep_id = sr.rep_id WHERE o.order_date >= '2024-01-01' ORDER BY o.order_date DESC;

-- LEFT JOINS
SELECT c.customer_id, c.company, COUNT(o.order_id) as total_orders, COALESCE(SUM(o.total_amount), 0) as total_revenue FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id GROUP BY c.customer_id, c.company ORDER BY total_revenue DESC;

SELECT sr.rep_id, CONCAT(sr.first_name, ' ', sr.last_name) as rep_name, sr.territory, COUNT(c.customer_id) as assigned_customers FROM sales_representatives sr LEFT JOIN customers c ON sr.rep_id = c.assigned_rep_id WHERE sr.status = 'Active' GROUP BY sr.rep_id, sr.first_name, sr.last_name, sr.territory ORDER BY assigned_customers DESC;

-- RIGHT JOINS
SELECT c.customer_id, c.company, sr.first_name as rep_first_name, sr.last_name as rep_last_name, sr.territory FROM customers c RIGHT JOIN sales_representatives sr ON c.assigned_rep_id = sr.rep_id WHERE sr.status = 'Active' ORDER BY sr.territory;

-- SUBQUERIES
SELECT customer_id, company, industry FROM customers WHERE assigned_rep_id IN (SELECT rep_id FROM sales_representatives WHERE territory = 'West Coast');

-- COMMON TABLE EXPRESSIONS (CTEs)
WITH active_customers AS (SELECT customer_id, company, industry, credit_limit FROM customers WHERE status = 'Active')
SELECT industry, COUNT(*) as customer_count, AVG(credit_limit) as avg_credit_limit FROM active_customers GROUP BY industry ORDER BY customer_count DESC;

WITH customer_orders AS (SELECT c.customer_id, c.company, c.industry, COUNT(o.order_id) as order_count, COALESCE(SUM(o.total_amount), 0) as total_revenue FROM customers c LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE c.status = 'Active' GROUP BY c.customer_id, c.company, c.industry),
customer_segments AS (SELECT *, CASE WHEN total_revenue >= 50000 THEN 'High Value' WHEN total_revenue >= 20000 THEN 'Medium Value' WHEN total_revenue > 0 THEN 'Low Value' ELSE 'No Orders' END as customer_segment FROM customer_orders)
SELECT customer_segment, COUNT(*) as customer_count, AVG(total_revenue) as avg_revenue, AVG(order_count) as avg_orders FROM customer_segments GROUP BY customer_segment ORDER BY avg_revenue DESC;

-- WINDOW FUNCTIONS
SELECT order_id, customer_id, order_date, total_amount, ROW_NUMBER() OVER (ORDER BY total_amount DESC) as revenue_rank, ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) as customer_order_sequence FROM orders ORDER BY total_amount DESC;

SELECT order_id, order_date, total_amount, SUM(total_amount) OVER (ORDER BY order_date ROWS UNBOUNDED PRECEDING) as running_total, AVG(total_amount) OVER (ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as moving_avg_3_orders FROM orders ORDER BY order_date;

SELECT RANK() OVER (ORDER BY total_revenue DESC) as performance_rank, rep_name, territory, customer_count, total_revenue, avg_deal_size, quota_attainment FROM (SELECT CONCAT(sr.first_name, ' ', sr.last_name) as rep_name, sr.territory, sr.quota, COUNT(DISTINCT c.customer_id) as customer_count, COALESCE(SUM(o.total_amount), 0) as total_revenue, COALESCE(AVG(o.total_amount), 0) as avg_deal_size, CASE WHEN sr.quota > 0 THEN ROUND((COALESCE(SUM(o.total_amount), 0) / sr.quota) * 100, 1) ELSE 0 END as quota_attainment FROM sales_representatives sr LEFT JOIN customers c ON sr.rep_id = c.assigned_rep_id LEFT JOIN orders o ON c.customer_id = o.customer_id WHERE sr.status = 'Active' GROUP BY sr.rep_id, sr.first_name, sr.last_name, sr.territory, sr.quota) as rep_performance ORDER BY total_revenue DESC;

-- CASE STATEMENTS
SELECT customer_id, company, credit_limit, CASE WHEN credit_limit >= 100000 THEN 'Premium' WHEN credit_limit >= 50000 THEN 'Standard' WHEN credit_limit >= 25000 THEN 'Basic' ELSE 'Starter' END as credit_tier FROM customers ORDER BY credit_limit DESC;

SELECT c.customer_id, c.company, c.status, c.industry, order_summary.total_orders, order_summary.total_revenue, CASE WHEN c.status = 'Churned' THEN 'Lost Customer' WHEN order_summary.total_revenue >= 75000 THEN 'VIP Customer' WHEN order_summary.total_revenue >= 25000 THEN 'Premium Customer' WHEN order_summary.total_orders >= 3 THEN 'Regular Customer' WHEN order_summary.total_orders >= 1 THEN 'New Customer' ELSE 'Prospect' END as customer_category, CASE WHEN c.last_contact_date IS NULL THEN 'Never Contacted' WHEN c.last_contact_date >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) THEN 'Recently Contacted' WHEN c.last_contact_date >= DATE_SUB(CURDATE(), INTERVAL 90 DAY) THEN 'Contacted This Quarter' ELSE 'Needs Follow-up' END as contact_status FROM customers c LEFT JOIN (SELECT customer_id, COUNT(*) as total_orders, SUM(total_amount) as total_revenue FROM orders GROUP BY customer_id) order_summary ON c.customer_id = order_summary.customer_id ORDER BY order_summary.total_revenue DESC;

-- 1. View for Active Customers with Highest Revenue
CREATE VIEW vw_high_value_active_customers AS
SELECT
    c.customerid,
    c.company,
    c.industry,
    c.status,
    COALESCE(SUM(o.totalamount), 0) AS total_revenue
FROM customers c
LEFT JOIN orders o ON c.customerid = o.customerid
WHERE c.status = 'Active'
GROUP BY c.customerid, c.company, c.industry, c.status
HAVING total_revenue > 50000
ORDER BY total_revenue DESC;

-- 2. View for Sales Representative Territory Performance
CREATE VIEW vw_territory_performance AS
SELECT
    sr.territory,
    COUNT(c.customerid) AS customer_count,
    COALESCE(SUM(o.totalamount), 0) AS territory_revenue,
    ROUND(COALESCE(SUM(o.totalamount), 0)/COUNT(c.customerid), 2) AS avg_customer_value
FROM salesrepresentatives sr
LEFT JOIN customers c ON sr.repid = c.assignedrepid
LEFT JOIN orders o ON c.customerid = o.customerid
WHERE sr.status = 'Active'
GROUP BY sr.territory
ORDER BY territory_revenue DESC;

-- Procedure to update last contact date for a customer
DELIMITER //
CREATE PROCEDURE UpdateLastContactDate(
    IN inputCustomerId INT,
    IN contactDate DATE
)
BEGIN
    UPDATE customers
    SET lastcontactdate = contactDate
    WHERE customerid = inputCustomerId;
END //
DELIMITER ;


-- 1. Trigger to update product stock after an order detail is inserted
DELIMITER //
CREATE TRIGGER after_orderdetail_insert
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    UPDATE products
    SET stockquantity = stockquantity - NEW.quantity
    WHERE productid = NEW.productid;
END //
DELIMITER ;

-- 2. Trigger to log change in customer's status
CREATE TABLE IF NOT EXISTS customer_status_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    customerid INT,
    old_status ENUM('Active','Inactive','Prospect','Churned'),
    new_status ENUM('Active','Inactive','Prospect','Churned'),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE TRIGGER after_customer_status_update
AFTER UPDATE ON customers
FOR EACH ROW
BEGIN
    IF OLD.status <> NEW.status THEN
        INSERT INTO customer_status_audit (customerid, old_status, new_status)
        VALUES (NEW.customerid, OLD.status, NEW.status);
    END IF;
END //
DELIMITER ;

-- DATABASE SUMMARY
SELECT 'Database Summary' as report_section, '' as metric, '' as value
UNION ALL
SELECT '', 'Total Tables', '11'
UNION ALL
SELECT '', 'Total Records', CAST((SELECT COUNT(*) FROM sales_representatives) + (SELECT COUNT(*) FROM customers) + (SELECT COUNT(*) FROM leads) + (SELECT COUNT(*) FROM products) + (SELECT COUNT(*) FROM orders) + (SELECT COUNT(*) FROM order_details) + (SELECT COUNT(*) FROM interactions) + (SELECT COUNT(*) FROM tasks) + (SELECT COUNT(*) FROM opportunities) + (SELECT COUNT(*) FROM campaigns) + (SELECT COUNT(*) FROM campaign_leads) AS CHAR)
UNION ALL
SELECT '', 'Active Customers', CAST((SELECT COUNT(*) FROM customers WHERE status = 'Active') AS CHAR)
UNION ALL
SELECT '', 'Total Orders', CAST((SELECT COUNT(*) FROM orders) AS CHAR)
UNION ALL
SELECT '', 'Total Revenue', CONCAT('$', FORMAT((SELECT SUM(total_amount) FROM orders), 2))
UNION ALL
SELECT '', 'Active Sales Reps', CAST((SELECT COUNT(*) FROM sales_representatives WHERE status = 'Active') AS CHAR);

