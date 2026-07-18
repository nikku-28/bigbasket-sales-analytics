# BigBasket Sales Analytics Dashboard

SQL + Power BI project analyzing sales trends, customer behavior, and product performance for a grocery e-commerce platform (inspired by BigBasket).

## Why I built this

I wanted to go through the full analyst workflow — clean data, write SQL that answers real business questions, and turn it into a dashboard someone could actually act on. I picked grocery/quick-commerce since it's a business everyone can relate to, and the questions (what's selling, who's buying, when demand spikes) felt close to real interview case studies.

## About the data

| Data | Source | Real or simulated |
|---|---|---|
| Product catalog | Kaggle — "BigBasket Entire Product List" (~28K products) | Real |
| Customers & Orders | Generated with SQL | Simulated |

BigBasket doesn't publish transaction data publicly, so I simulated a year of orders on top of the real product catalog — built with realistic patterns (weekend spikes, a festive-season surge around Diwali, popular categories ordered more often, mostly small basket sizes) rather than pure randomness. Being upfront about what's real vs. simulated felt like the right call.

## Tools
MySQL 8.0 · Power BI Desktop

## Approach
1. Loaded the real product catalog into MySQL (~28K rows)
2. Generated customers (2,000) and orders (15,000, across 2023) using SQL recursive CTEs
3. Wrote analysis queries using window functions (RANK, NTILE, LAG) — revenue trends, category/product performance, RFM segmentation, pricing
4. Built 3 SQL views to feed a clean data model into Power BI
5. Built a 2-page interactive dashboard

## Key Findings

1. **Festive season drives a real spike** — revenue jumped ~46% in October, roughly doubling the monthly baseline.
2. **Kitchen & cookware dominate best-sellers** — 4 of the top 10 products by revenue are cookware items.
3. **Revenue is concentrated in a few SKUs** — one brand (Huggies) earned ~65% more than the next brand, from just 2 products.
4. **Volume ≠ value** — Kolkata has the most customers and highest total revenue, but Lucknow/Ahmedabad customers spend more per head.
5. **53% of customers are loyal, 25% are at risk** — RFM segmentation shows a healthy loyal base but a real churn risk segment. Interestingly, revenue is nearly even across account tiers (Premium/Regular/New), so behavior (RFM) predicts value better than the tier label.

## Dashboard

**Page 1 — Sales Overview:** KPI cards, monthly revenue trend, revenue by category, top 10 products
**Page 2 — Customer Segmentation:** RFM segment breakdown, revenue by city, revenue by account type

*(Screenshots below)*

## Reproduce it
1. Download the BigBasket product dataset from Kaggle → load into MySQL as `products`
2. Run `generate_synthetic_data.sql` → creates `customers` and `orders`
3. Run `analysis_queries.sql` and `create_views.sql`
4. In Power BI: Get Data → MySQL Database → connect → load the 3 views
5. Or just open the included `.pbix` directly

## Folder structure
```
DA project/
├── README.md
├── data/BigBasketProducts.csv
├── sql/ (generate_synthetic_data.sql, analysis_queries.sql, create_views.sql)
├── powerbi/bigbasket_dashboard.pbix
└── screenshot/ (page1, page2)
```

---
Built as part of placement prep — happy to walk through any part of it in more detail.
