# MLaaS
Machine Learning as a Service project for college Data Product course.

## Project Description

The project goal was to create an API able to consume a Machine Learning Model of our choice. Such API was to have three different endpoints: one for individual predictions, the second one for batch predicting, and a third one for testing performance metrics of the model. Logging on the server side was also a must. 

### Data

The dataset chosen for this project belongs to the **MLbench** package and it's titled **Breast Cancer**. This dataset originally contains 699 observations and 11 features regarding to biopsy samples taken from breast to test if the them were cancerogenous.  
For this model, only 4 of those features were used: Cell thickness, Cell size, Cell shape, and Class (which establishes wether the sample is benign or malignant).

### Model

Since the nature of the problem was what is commonly called a **Binary Classification Problem**, a **Logistic Regression** was ideal. Logistic Regression is a classic predictive modelling technique used when we only have two possible outcomes from a given event. In this case, the LR model was used to predict if a given mass of tissue is benign or malignant, based on the characteristics from the biopsy mentioned above (thickness, size, and shape). The model, using these three features, achieved a test accuracy a little over 94%, more than enough for our demonstrative purposes.

### Endpoints

Once the model was built, the API was created with the help of **Plumber**, a very useful package for R.  
All endpoints first go through two filters, the first one checks for user validation, and yields an error if the user given is not registered. The second one, saves information about the request that later is used for logging.

#### /predict_single

This endpoint serves individual prediction requests, the parameters needed are:
* User
* Cell thickness
* Cell size
* Cell shape

The outcome, is either "Benign" or "Malignant" to explain if the tissue is cancerogenous or not.

#### /predict_multiple

This endpoint serves batch predicting, given any number of different tissue samples, the parameters needed are:
* User
* Cells' thickness
* Cells' size
* Cells' shape

The outcome, just like the previous one, is an array containing either "Benign" or "Malignant" labels to the respective observations.

#### /performance_metrics

This endpoint serves performance testing, similar to the batch predicting endpoint, it receives a number of observations and also their actual Class. So the endpoint first predicts for all observations, and then compares with the actual values to generate multiple performance metrics that will son be listed. The parameter needed are:
* User
* Cells' thickness
* Cells' size
* Cells' shape
* Cells' actual class

The outcome is a list of metrics regarding the model performance, such as: Confusion Matrix, AUC, Accuracy, Recall, Precision, and Specificity. 

### Logs 

All of the endpoints, generate logs in the server side every time a request is made, in order to have a temporary history of events. The parameters logged per request are:
* Timestamp of event
* User (who is making the request), or a Warning Log in case the user is invalid
* Enpoint requested
* User agent (from what sort of platform is the request coming)
* Payload received (depending on the endpoint selected)
* Output (depending on the endpoint selected)

### Test Files

Within this repository, you can find sample test files to try the API. There is one test file corresponding to each endpoint. Using **Postman** as your request testing tool is advice, since it's the platform in which the test files were generated with.

### Deployment

To finish the whole process of building a model and creating an API, it is key to deploy our service on the web, so it can be accesed from wherever we want to. In roder to do so, this API was deployed on a EC2 rented from AWS. 
With this, you have to options to test this project: 
* **Test local:** you can clone this repository, and use RStudio (or Rscript in the terminal) and Postman directly on your computer in order to recreate the API. 
* **Test service hosted by me:** the EC2 will be publicly available for a limited time (2-3 weeks from the current commit date), so anyone can test the API without having to run it on RStudio or your terminal. All you need is Postman running on your computer and copying or downloading the **Test files** available here. The IP of the service is: **3.84.60.20**.

And remember, than in either a local or hosted enviroment, the API is running on the **8008 port** (and you could change so in the R scripts if needed).

