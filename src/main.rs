use actix_web::{web, App, HttpServer, get};
use std::sync::Mutex;

struct AppState {
    counter: Mutex<i32>,
}

#[get("/")]
async fn index(data: web::Data<AppState>) -> String {
    let mut counter = data.counter.lock().unwrap();
    *counter += 1;
    format!("Counter is at {}", counter)
}

#[actix_rt::main]
async fn main() -> std::io::Result<()> {
    let app_state = web::Data::new(AppState {
        counter: Mutex::new(0),
    });
    HttpServer::new(move || {
        App::new()
        .app_data(app_state.clone())
        .service(index)
    }).bind("127.0.0.1:8080")?.run().await
}