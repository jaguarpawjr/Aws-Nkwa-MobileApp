class OnboardingPageData {
  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  final String title;
  final String description;
  final String imagePath;
}

const onboardingPages = [
  OnboardingPageData(
    title: "Speak your language. We'll handle the rest.",
    description:
        "In an emergency, just talk. Our AI understands Twi, Ga, Ewe, Hausa and more — turning your words into the right alert, in real time.",
    imagePath: 'assets/2.png',
  ),
  OnboardingPageData(
    title: 'First aid, even offline.',
    description:
        'Search step-by-step guides for burns, falls, choking and more. Everything works without an internet connection.',
    imagePath: 'assets/3.png',
  ),
  OnboardingPageData(
    title: 'Your circle, ready to respond.',
    description:
        "Add the people you trust. They'll get a high-priority alert with your location the second you need help.",
    imagePath: 'assets/1.png',
  ),
  OnboardingPageData(
    title: 'One tap. Instant alert.',
    description:
        'Press the panic button to instantly notify your emergency contacts and nearby dispatchers with your live location.',
    imagePath: 'assets/4.png',
  ),
];
