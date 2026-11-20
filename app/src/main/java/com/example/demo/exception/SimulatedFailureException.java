package com.example.demo.exception;

// Thrown on purpose by the demo hook in BorrowService to prove that the transaction rolls back.
public class SimulatedFailureException extends RuntimeException {
    public SimulatedFailureException(String message) {
        super(message);
    }
}
