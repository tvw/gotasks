package dummy_test

import (
	"testing"
	"dummypkg"
)

func TestDummy1(t *testing.T){
	if dummypkg.DummyFunc1("Hello World") != "Hello World" {
		t.Error("DummyFunc1 does not return 'Hello World'")
	}
}

func TestDummy2(t *testing.T){
	if dummypkg.DummyFunc2("Hello World") != "Hello World" {
		t.Error("DummyFunc2 does not return 'Hello World'")
	}
}
