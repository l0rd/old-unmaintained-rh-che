/*******************************************************************************
 * Copyright (c) 2012-2017 Red Hat, Inc.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *   Red Hat, Inc. - initial API and implementation
 *******************************************************************************/
package com.redhat.bayesian.lsp.server;

import static java.util.Arrays.asList;

import java.io.IOException;

import com.google.inject.Inject;
import com.google.inject.Singleton;

import org.eclipse.che.api.languageserver.exception.LanguageServerException;
import org.eclipse.che.api.languageserver.launcher.LanguageServerLauncherTemplate;
import org.eclipse.che.api.languageserver.shared.model.LanguageDescription;
import org.eclipse.che.api.languageserver.shared.model.impl.LanguageDescriptionImpl;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import io.typefox.lsapi.services.json.JsonBasedLanguageServer;

/**
 * 
 */
@SuppressWarnings("deprecation")
@Singleton
public class BayesianServerLauncher extends LanguageServerLauncherTemplate {
	private static final String LANGUAGE_ID = "Bayesian";
	private static final String[] EXTENSIONS = new String[] { "json" };
	private static final String[] MIME_TYPES = new String[] { "application/json" };
	private static final LanguageDescriptionImpl description;
	private final Path launchScript;

	static {
		description = new LanguageDescriptionImpl();
		description.setFileExtensions(asList(EXTENSIONS));
		description.setLanguageId(LANGUAGE_ID);
		description.setMimeTypes(asList(MIME_TYPES));
	}

	@Inject
	public BayesianServerLauncher() {
		launchScript = Paths.get(System.getenv("HOME"), "che/ls-bayesian/server/server.js");
	}

	@Override
	public LanguageDescription getLanguageDescription() {
		return description;
	}

    @Override
    public boolean isAbleToLaunch() { return Files.exists(launchScript); }

	protected JsonBasedLanguageServer connectToLanguageServer(Process languageServerProcess) {
		JsonBasedLanguageServer languageServer = new JsonBasedLanguageServer();
		languageServer.connect(languageServerProcess.getInputStream(), languageServerProcess.getOutputStream());
		return languageServer;
	}

	protected Process startLanguageServerProcess(String projectPath) throws LanguageServerException {
		ProcessBuilder processBuilder = new ProcessBuilder("node", launchScript.toString(), "--stdio");
		processBuilder.redirectInput(ProcessBuilder.Redirect.PIPE);
		processBuilder.redirectOutput(ProcessBuilder.Redirect.PIPE);

		try {
			Process p = processBuilder.start();
			return p;
		} catch (IOException e) {
			throw new LanguageServerException("Can't start Bayesian language server", e);
		}
	}
}
