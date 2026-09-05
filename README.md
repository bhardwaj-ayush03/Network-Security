# Network Security Threat Detection — ML Pipeline

A phishing / network-threat classifier, built as a full pipeline rather than a single notebook. The idea was to treat this like a real ML system: data flows through separate ingestion, validation, transformation, training, and serving stages, each one independently testable and swappable.

## What it does

Given URL and website-based features, the pipeline classifies whether a site is a phishing/security threat. The interesting part isn't the model itself (Scikit-learn classifiers) — it's the plumbing around it: schema-checked ingestion from a live database, tracked experiments, and a containerized deployment that actually serves predictions over an API.


## Deployment walkthroughs

- [Setting up the S3 bucket for model artifacts](https://youtu.be/EjjJrggSYEY)
- [Pushing the Docker image to Amazon ECR](https://youtu.be/bILQogVMZDg)
- [Deploying live on an EC2 instance](https://youtu.be/-gSspNm1UCA)


## How data moves through it

```
MongoDB Atlas (raw data)
        │
        ▼
   Data Ingestion
        │
        ▼
  Data Validation  ──► flags schema drift before it reaches training
        │
        ▼
 Data Transformation ──► saves reusable preprocessing artifact
        │
        ▼
   Model Trainer ──► logged to MLflow (tracked via DagsHub)
        │
        ▼
 FastAPI Prediction Service
```

## How it ships

```
push to main
   │
   ▼
GitHub Actions: lint + test (CI)
   │
   ▼
GitHub Actions: build Docker image (CD)
   │
   ▼
image pushed to AWS ECR
   │
   ▼
self-hosted EC2 runner pulls latest image
   │
   ▼
container runs the FastAPI service, pulling model artifacts from S3 at runtime
```

## Code layout

The package follows a `constants → entity/config → components → artifacts` flow — config values are centralized, config classes wrap them, components do the actual work, and every run's outputs land in a versioned artifacts folder.

```
NETWORK_SECURITY/
├── .github/workflows/       # CI/CD
├── Artifacts/                # outputs per pipeline run
├── Network_data/             # raw dataset
├── data_schema/               # schema used for validation
├── logs/
├── network_security/
│   ├── components/            # data_ingestion, data_validation, data_transformation, model_trainer
│   ├── entity/                 # config_entity, artifact_entity
│   ├── exception/
│   └── logging/
├── main.py                    # runs the full training pipeline
├── push_data.py                # loads raw data into MongoDB
├── Dockerfile
├── requirements.txt
└── setup.py
```

## Stack

- **Data**: MongoDB Atlas, pymongo
- **ML**: Scikit-learn, Pandas, NumPy
- **Tracking**: MLflow + DagsHub
- **Serving**: FastAPI, Uvicorn
- **Deploy**: Docker, GitHub Actions (self-hosted runner), AWS S3 / ECR / EC2
- **Config**: python-dotenv, pyaml

## Running it locally

```bash
git clone https://github.com/bhardwaj-ayush03/NETWORK_SECURITY.git
cd NETWORK_SECURITY

pip install -r requirements.txt

# add to .env
MONGO_DB_URL=<your-mongodb-atlas-connection-string>

# one-time: load raw data into MongoDB
python push_data.py

# run the full training pipeline
python main.py

# serve predictions
uvicorn app:app --reload
```

Swagger docs available at `http://localhost:8080/docs` once the service is up.

## What I'd add next

- Drift monitoring post-deployment (e.g. Evidently) instead of relying only on pre-training validation
- Auto-retraining triggered once drift crosses a threshold
- Auth on the FastAPI service before it's exposed publicly
- Statistical checks in the validation stage, not just structural schema checks

## 🤝 Contributing

Pull requests are welcome. For major changes, open an issue first to discuss what you'd like to change.

---

## 👤 Author

**Ayush Bhardwaj**


[![GitHub](https://img.shields.io/badge/GitHub-bhardwaj--ayush03-181717?logo=github)](https://github.com/bhardwaj-ayush03)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-ayushbhardwaj03-0A66C2?logo=linkedin)](https://linkedin.com/in/ayushbhardwaj03)

