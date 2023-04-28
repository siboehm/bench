package main

import (
	"fmt"
)

//go:inline
func FooInline(w float32) float32 {
	pw := (1 - w) / w
	return (1 / (1 + pw*pw*pw*pw*pw*pw))
}

//go:noinline
func FooNoInline(w float32) float32 {
	pw := (1 - w) / w
	return (1 / (1 + pw*pw*pw*pw*pw*pw))
}

func main() {
	i := float32(0.47227675)
	inlineOut := FooInline(i)
	outNoInline := FooNoInline(i)
	fmt.Println("inlineOut:  ", inlineOut)
	fmt.Println("noInlineOut:", outNoInline)
}
